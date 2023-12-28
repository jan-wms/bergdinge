import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void copyToClipboard(
    {required BuildContext context, required String value}) async {
  Clipboard.setData(ClipboardData(text: value)).then((_) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("In die Zwischenablage kopiert"),
    ));
  });
}