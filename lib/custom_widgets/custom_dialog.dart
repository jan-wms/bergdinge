import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomDialog {
  static Future<T> showCustomModal<T>(
      {required BuildContext context, required Widget child}) async {
    return await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
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
            return Center(
              child: child,
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
        useRootNavigator: true,
        barrierDismissible: false,
        builder: (context) => Align(
          //TODO breakpoint1 .center
        alignment: Alignment.bottomCenter,
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 300,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(20),
          width: double.infinity,
          child: child,
            )));
  }

  static Future<bool?> showCustomConfirmationDialog<bool>(
      {required BuildContext context, required String description}) async {
    final Widget child =  Column(
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
                onPressed: () => context.pop(true),
                child: const Text('Ok')),
          ],
        )
      ],
    );
    return await showCustomDialog(context: context, child: child);
  }

  static Future<bool?> showCustomInformationDialog(
      {required BuildContext context, required String description}) async {
    final Widget child =  Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(description),
        ElevatedButton(
            onPressed: () => context.pop(true), child: const Text('Ok')),
      ],
    );

    return await showCustomDialog(context: context, child: child);
  }
}
