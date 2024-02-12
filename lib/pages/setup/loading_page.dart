import 'dart:async';

import 'package:flutter/material.dart';

class LoadingPage extends StatefulWidget {
  final VoidCallback onInit;
  const LoadingPage({super.key, required this.onInit});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  final messages = [
    'Bergdinge wird eingerichtet.',
    'Einen Moment bitte.',
    'Bergdinge wird eingerichtet.',
    'Bergdinge wird eingerichtet.',
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
