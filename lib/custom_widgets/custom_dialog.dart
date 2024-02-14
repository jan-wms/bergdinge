
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/design.dart';

enum ConfirmType {
  confirmDelete,
  confirmContinue,
  confirmDefault,
}

class CustomDialog {
  static Future<T> showCustomModal<T>(
      {required BuildContext context,
      required Widget child,
      bool isFullscreen = false}) async {
    //TODO breakpoint
    if(MediaQuery.of(context).size.width > Design.breakpoint1) {
      return showCustomDialog(context: context, child: Material(color: Colors.transparent,child: child,));
    }


    return await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      enableDrag: isFullscreen ? false : true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: isFullscreen ? 1.0 : 0.9,
          maxChildSize: isFullscreen ? 1.0 : 0.9,
          minChildSize: isFullscreen ? 1.0 : 0.9,
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
            alignment: MediaQuery.of(context).size.width > Design.breakpoint1 ? Alignment.center :  Alignment.bottomCenter,
            child: Container(
              constraints:
              BoxConstraints(minHeight: 250, maxHeight: MediaQuery.of(context).size.height * 0.7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              margin: const EdgeInsets.all(20),
              child: child,
            )));
  }

  static Future<bool?> showCustomConfirmationDialog<bool>(
      {required BuildContext context,
      required String description,
      required ConfirmType type}) async {
    final Color buttonColor;
    final String buttonText;

    switch (type) {
      case ConfirmType.confirmDelete:
        buttonColor = Theme.of(context).colorScheme.error;
        buttonText = 'Löschen';
        break;
      case ConfirmType.confirmContinue:
        buttonColor = Design.colors[0];
        buttonText = 'Weiter';
        break;
      case ConfirmType.confirmDefault:
      default:
        buttonColor = Design.colors[0];
        buttonText = 'OK';
        break;
    }

    final Widget child = Material(
      color: Colors.white,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 400.0,
        ),
        child: Column(
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
                style:
                    const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500),
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
                        backgroundColor: buttonColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0))),
                    onPressed: () => context.pop(true),
                    child: Text(
                      buttonText,
                      style: const TextStyle(fontSize: 17),
                    ))
              ],
            )
          ],
        ),
      ),
    );
    return await showCustomDialog(context: context, child: child);
  }

  static Future<bool?> showCustomInformationDialog(
      {required BuildContext context, required String description}) async {
    final Widget child = Container(
      padding: const EdgeInsets.all(20.0),
      constraints: const BoxConstraints(
        maxWidth: 400.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Colors.black45,
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
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.only(
                      left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
                  foregroundColor: Colors.white,
                  backgroundColor: Design.colors[0],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0))),
              onPressed: () => context.pop(true),
              child: const Text(
                'OK',
                style: TextStyle(fontSize: 17),
              ))
        ],
      ),
    );

    return await showCustomDialog(context: context, child: child);
  }
}
