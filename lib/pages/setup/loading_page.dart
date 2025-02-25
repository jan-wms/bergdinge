import 'dart:async';

import 'package:bergdinge/pages/setup/setup_screen.dart';
import 'package:flutter/material.dart';

class LoadingPage extends StatefulWidget {
  final EditValue editValue;
  final VoidCallback onInit;
  const LoadingPage({super.key, required this.onInit, required this.editValue});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  late final defaultMessage = (widget.editValue == EditValue.name) ? 'Dein Profil wird aktualisiert.' : 'Bergdinge wird eingerichtet.';
  late final messages = [
    defaultMessage,
    'Einen Moment bitte.',
    defaultMessage,
    defaultMessage,
    'Eine stabile Internetverbindung ist erforderlich.'
  ];

  int messageIndex = 0;

  late final Timer timer;

  @override
  void initState() {
    super.initState();
    widget.onInit();

    timer = Timer.periodic(const Duration(seconds: 3), (t) {
      if (messageIndex < messages.length - 1) {
        setState(() {
          messageIndex++;
        });
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: Column(
              children: [
                Text(messages[messageIndex], style: const TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
