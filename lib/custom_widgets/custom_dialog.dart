import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

class CustomDialog {
  static Future<T> showCustomModal<T>(
      BuildContext context, Widget child, Widget? left, Widget right) async {
    return await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          maxChildSize: 0.9,
          minChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    left ?? Container(),
                    right,
                  ],
                ),
                Expanded(
                  child: child,
                ),
              ],
            );
          },
        );
      },
    );
  }

  static Future<T> showCustomDialog<T>(
      {required BuildContext context, required Widget child}) async {
    return await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
              child: child,
            ));
  }

  static Future<bool?> showCustomConfirmationDialog<bool>(
      {required BuildContext context, required String description}) async {
    final child = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(description),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
                onPressed: () => context.pop(false),
                child: const Text('Abbrechen')),
            ElevatedButton(
                onPressed: () => context.pop(true), child: const Text('Ok')),
          ],
        )
      ],
    );
    return await showCustomDialog<bool>(context: context, child: child);
  }

  static Future<void> showCustomInformationDialog(
      {required BuildContext context, required String description}) async {
    final child = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(description),
        ElevatedButton(onPressed: () => context.pop(), child: const Text('Ok')),
      ],
    );
    return await showCustomDialog<void>(context: context, child: child);
  }

  static Future<void> showRequestPermissionDialog(
      BuildContext context, Permission permission) async {
    late final String title;
    late final String content;

    if(permission == Permission.photos) {
      title = 'Equipment App hat keinen Zugriff auf deine Fotos';
      content = 'Tippe auf Einstellungen und aktiviere Fotos.';
    } else if(permission == Permission.camera) {
      title = 'Equipment App hat keinen Zugriff auf deine Kamera';
      content = 'Tippe auf Einstellungen und aktiviere Kamera.';
    } else if(permission == Permission.microphone) {
      title = 'Equipment App hat keinen Zugriff auf dein Mikrofon';
      content = 'Tippe auf Einstellungen und aktiviere Mikrofon.';
    } else {
      title = 'Equipment App fehlen Zugriffsberechtigungen';
      content = 'Tippe auf Einstellungen und aktiviere alle Zugriffsberechtigungen.';
    }

    if (Platform.isIOS) {
      return await showCupertinoDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Abbrechen'),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.pop(context);
                openAppSettings();
              },
              child: const Text('Einstellungen'),
            ),
          ],
        ),
      );
    }
    final child = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title),
        Text(content),
        Row(
          children: [
            TextButton(
                onPressed: () => context.pop(), child: const Text('Abbrechen')),
            ElevatedButton(
                onPressed: () {
                  context.pop();
                  openAppSettings();
                },
                child: const Text('Einstellungen')),
          ],
        )
      ],
    );
    return await showCustomDialog<void>(context: context, child: child);
  }
}
