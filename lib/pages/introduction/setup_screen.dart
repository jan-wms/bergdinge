import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:equipment_app/custom_widgets/custom_dialog.dart';
import 'package:equipment_app/image_crop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../firebase/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({Key? key}) : super(key: key);

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  late final bool isMobile = kIsWeb || Platform.isMacOS ? false : true;
  final _pageController = PageController(initialPage: 0);
  final _formKey = GlobalKey<FormState>();
  final _textFieldController =
      TextEditingController(text: Auth().user!.displayName);

  String selectedName = '';
  final ImagePicker picker = ImagePicker();
  Uint8List image = Uint8List(0);

  @override
  void initState() {
    super.initState();
    preLoadImage();
  }

  Future<void> preLoadImage() async {
    final photoURL = Auth().user!.photoURL;
    if (photoURL != null) {
      var dio = Dio();

      try {
        Response response = await dio.get(
          photoURL,
          options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
          ),
        );
        image = response.data;
      } catch (e) {
        print(e);
      }
    }
  }

  void pickImage({required ImageSource? imageSource}) async {
    late final Uint8List? selectedImg;
    if(imageSource == null) {
      selectedImg = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'jpeg'],
      ).then((value) => value?.files.single.bytes);
    } else {
      if (await checkPermissions(imageSource) == false) return;
      selectedImg = await picker.pickImage(source: imageSource).then((value) async { return await value?.readAsBytes();});
    }

    if (selectedImg != null && context.mounted) {
        Uint8List? cropImg = await Navigator.of(context).push<Uint8List?>(
          MaterialPageRoute<Uint8List?>(
              builder: (context) => ImageCrop(image: selectedImg!)),
        );
        setState(() {
          if (cropImg != null) image = cropImg;
        });
    }
  }

  Future<bool> checkPermissions(ImageSource imageSource) async {
    if (imageSource == ImageSource.gallery && Platform.isIOS) {
      bool photosPermission = await Permission.photos.request().isGranted;
      if (!photosPermission) {
        if (context.mounted) {
          CustomDialog.showRequestPermissionDialog(context, Permission.photos);
        }
        return false;
      }
    } else if (imageSource == ImageSource.camera) {
      bool photosPermission = await Permission.camera.request().isGranted;
      if (!photosPermission) {
        if (context.mounted) {
          CustomDialog.showRequestPermissionDialog(context, Permission.camera);
        }
        return false;
      }
    }
    return true;
  }

  Future<void> uploadToFirebase({required bool hasImage}) async {
    await _pageController.nextPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);

    if (hasImage) {
      final storageRef = FirebaseStorage.instance.ref();
      final imageRef =
          storageRef.child("users/${Auth().user!.uid}/profile.jpg");
      await imageRef.putData(
          image,
          SettableMetadata(
            contentType: "image/jpg",
          ));
    }

    DocumentReference ref =
        FirebaseFirestore.instance.collection('users').doc(Auth().user?.uid);
    await ref.set({
      "name": selectedName,
      "isSetupCompleted": true,
      "email": Auth().user?.email
    }, SetOptions(merge: true));

    Auth().user!.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Wie heißt du?'),
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Name'),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Bitte gib deinen Namen ein.';
                        }
                        return null;
                      },
                      controller: _textFieldController,
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            selectedName = _textFieldController.text;
                          });
                          _pageController.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut);
                        }
                      },
                      child: const Text('Weiter'))
                ],
              ),
            ),
            Center(
              child: Column(
                children: [
                  Text(selectedName),
                  CircleAvatar(
                    radius: 48,
                    backgroundImage: (image.isNotEmpty)
                        ? Image.memory(image).image
                        : Image.asset('assets/images/placeholder.jpg').image,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          onPressed: () => pickImage(imageSource: isMobile ? ImageSource.gallery : null),
                          child: const Text('image_picker')),
                      if (isMobile)
                        IconButton(
                            onPressed: () => pickImage(imageSource: ImageSource.camera),
                            icon: const Icon(Icons.camera_alt_rounded)),
                    ],
                  ),
                  ElevatedButton(
                      onPressed: () {
                        if (image.isNotEmpty) {
                          uploadToFirebase(hasImage: true);
                        } else {
                          CustomDialog.showCustomInformationDialog(
                              context: context,
                              description: 'Bitte wähle ein Bild');
                        }
                      },
                      child: const Text('Los geht\'s')),
                  TextButton(
                      onPressed: () => uploadToFirebase(hasImage: false),
                      child: const Text('Überspringen')),
                ],
              ),
            ),
            const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator.adaptive(),
                  Text('App wird eingerichtet...'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
