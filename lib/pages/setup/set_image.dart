import 'dart:io';
import 'package:equipment_app/pages/setup/image_selector.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../custom_widgets/custom_dialog.dart';
import '../../firebase/firebase_auth.dart';

class SetImage extends StatefulWidget {
  final ValueSetter<Uint8List?> onComplete;

  const SetImage({super.key, required this.onComplete});

  @override
  State<SetImage> createState() => _SetImageState();
}

class _SetImageState extends State<SetImage> {
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
                      : Image.asset('assets/images/placeholder.jpg').image,
                ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () => ImageSelector().pickImage(
                    context: context,
                      imageSource: ImageSource.gallery),
                  child: const Text('image_picker')),
              if (isMobile)
                IconButton(
                    onPressed: () => ImageSelector().pickImage(context: context, imageSource: ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_rounded)),
            ],
          ),
          ElevatedButton(
              onPressed: () {
                if (image != null && image!.isNotEmpty) {
                } else {
                  CustomDialog.showCustomInformationDialog(
                      context: context, description: 'Bitte wähle ein Bild');
                }
              },
              child: const Text('Fertig')),
          context.canPop()
              ? TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Abbrechen'))
              : TextButton(onPressed: () {}, child: const Text('Überspringen')),
        ],
      ),
    );
  }
}
