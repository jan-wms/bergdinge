import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void copyToClipboard(
    {required BuildContext context, required String value}) async {
  Clipboard.setData(ClipboardData(text: value)).then((_) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      showCloseIcon: true,
      shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
      content: const Text("In die Zwischenablage kopiert"),
    ));
  });
}