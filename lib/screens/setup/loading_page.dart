import 'dart:async';

import 'package:bergdinge/screens/setup/setup_screen.dart';
import 'package:flutter/material.dart';

class LoadingPage extends StatefulWidget {
  final EditValue editValue;
  final VoidCallback onInit;
  const LoadingPage({super.key, required this.onInit, required this.editValue});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  late final defaultMessage = (widget.editValue == EditValue.name) ? 'Dein Profil wird aktualisiert.' : (widget.editValue == EditValue.none) ? 'Bergdinge' : 'Bergdinge wird eingerichtet.';
  late final messages = [
    defaultMessage,
    if(widget.editValue == EditValue.setUp) 'Beispiel-Daten werden geladen.',
    'Einen Moment bitte.',
    defaultMessage,
    if(widget.editValue == EditValue.setUp) 'Beispiel-Daten werden geladen.',
    defaultMessage,
    'Eine stabile Internetverbindung ist erforderlich.'
  ];

  int messageIndex = 0;

  late final Timer timer;

  @override
  void initState() {
    super.initState();
    widget.onInit();

    timer = Timer.periodic(const Duration(seconds: 2), (t) {
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
    timer.cancel();
    super.dispose();
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
            child: Text(messages[messageIndex], style: const TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}
