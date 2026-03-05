import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void copyToClipboard(
    {required BuildContext context, required String value}) async {
  await Clipboard.setData(ClipboardData(text: value));

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        width: min(MediaQuery.of(context).size.width * 0.9, 500),
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        content: const Text("In die Zwischenablage kopiert."),
      ),
    );
  }
}
