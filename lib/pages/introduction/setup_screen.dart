import 'dart:io';
import 'package:equipment_app/custom_widgets/show_custom_dialog.dart';
import 'package:equipment_app/data_models/user_info.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../firebase/firebase_auth.dart';

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
  var photoUrl = Auth().user!.photoURL;

  late UserInfo userInfo;

  @override
  void initState() {
    // TODO: Pre-Load user.photoUrl
    super.initState();
  }

  final ImagePicker picker = ImagePicker();
  late XFile? image = null;

  void pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
    }
  }

  void pickImage(ImageSource imageSource) async {
    if (await checkPermissions(imageSource)) {
      final img = await picker.pickImage(source: imageSource);
      setState(() {
        if (img != null) image = img;
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
        if (context.mounted)
          CustomDialog.showRequestPermissionDialog(context, Permission.camera);
        return false;
      }
    }

    return true;
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
                          return 'Bitte einen gültigen Namen eingeben.';
                        }
                        return null;
                      },
                      controller: _textFieldController,
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
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
                  /*ImageNetwork(
                    image: photoUrl!,
                    height: 200,
                    width: 200,
                  ),*/
                  if (image != null) Image.file(File(image!.path)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            if (isMobile) {
                              pickImage(ImageSource.gallery);
                            } else {
                              pickFile();
                            }
                          },
                          child: const Text('image_picker')),
                      if(isMobile) IconButton(
                          onPressed: () => pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera_alt_rounded)),
                    ],
                  ),
                ],
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
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
