import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../custom_widgets/custom_dialog.dart';
import '../../image_crop.dart';

class ImageSelector {
  final ImagePicker picker = ImagePicker();

  Future<Uint8List?> pickImage({required BuildContext context, required ImageSource imageSource}) async {
    late final Uint8List? selectedImg;
    if (kIsWeb || Platform.isMacOS) {
      selectedImg = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'jpeg'],
      ).then((value) => value?.files.single.bytes);
    } else {
      if (await checkPermissions(context: context, imageSource: imageSource) == false) return null;
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
      return cropImg;
    }
    return null;
  }

  Future<bool> checkPermissions({required BuildContext context, required ImageSource imageSource}) async {
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
}