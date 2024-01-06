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
                minHeight: 250,
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
    final Widget child = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Icon(
          Icons.warning_rounded,
          color: Color.fromRGBO(189, 166, 57, 1.0),
          size: 50.0,
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 40.0),
          child: Text(
            description,
            style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),
            softWrap: true,
            textAlign: TextAlign.center,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
                onPressed: () => context.pop(false),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black54,
                ),
                child: const Text(
                  'Abbrechen',
                  style: TextStyle(fontSize: 17),
                )),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.only(
                        left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
                    foregroundColor: Colors.white,
                    backgroundColor: Theme.of(context).colorScheme.error,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0))),
                onPressed: () => context.pop(true),
                child: const Text(
                  'Löschen',
                  style: TextStyle(fontSize: 17),
                ))
          ],
        )
      ],
    );
    return await showCustomDialog(context: context, child: child);
  }

  static Future<bool?> showCustomInformationDialog(
      {required BuildContext context, required String description}) async {
    final Widget child = Column(
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
