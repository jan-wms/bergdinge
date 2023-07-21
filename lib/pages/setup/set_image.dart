import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../custom_widgets/custom_dialog.dart';
import '../../firebase/firebase_auth.dart';
import '../../image_crop.dart';


class SetImage extends StatefulWidget {
  final ValueSetter<Uint8List?> onComplete;
  const SetImage({super.key, required this.onComplete});

  @override
  State<SetImage> createState() => _SetImageState();
}

class _SetImageState extends State<SetImage> {
  final ImagePicker picker = ImagePicker();
  Uint8List? image;

  late final bool isMobile = kIsWeb || Platform.isMacOS ? false : true;

  Future<void> preLoadImage() async {
    Uint8List? storageImage = await FirebaseStorage.instance
        .ref()
        .child("users/${Auth().user!.uid}/profile.jpg")
        .getData();

    setState(() {
      image = storageImage ?? Uint8List(0);
    });
  }


  void pickImage({required ImageSource? imageSource}) async {
    late final Uint8List? selectedImg;
    if (imageSource == null) {
      selectedImg = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'jpeg'],
      ).then((value) => value?.files.single.bytes);
    } else {
      if (await checkPermissions(imageSource) == false) return;
      selectedImg =
      await picker.pickImage(source: imageSource).then((value) async {
        return await value?.readAsBytes();
      });
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


  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Text('hallo <Name>'),
          image == null
              ? const CircularProgressIndicator.adaptive()
              : CircleAvatar(
            radius: 48,
            backgroundImage: (image!.isNotEmpty)
                ? Image.memory(image!).image
                : Image.asset('assets/images/placeholder.jpg')
                .image,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () => pickImage(
                      imageSource:
                      isMobile ? ImageSource.gallery : null),
                  child: const Text('image_picker')),
              if (isMobile)
                IconButton(
                    onPressed: () =>
                        pickImage(imageSource: ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_rounded)),
            ],
          ),
          ElevatedButton(
              onPressed: () {
                if (image != null && image!.isNotEmpty) {

                } else {
                  CustomDialog.showCustomInformationDialog(
                      context: context,
                      description: 'Bitte wähle ein Bild');
                }
              },
              child: const Text('Fertig')),
          TextButton(
              onPressed: () {},
              child: const Text('Überspringen')),
        ],
      ),
    );
  }
}
