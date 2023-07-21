import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equipment_app/firebase/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum ButtonText {
  continueText,
  doneText
}

late final Provider<String> newNameProvider;

class SetName extends StatefulWidget {
  final ButtonText buttonText;
  final VoidCallback onComplete;
  const SetName({super.key, required this.buttonText, required this.onComplete});

  @override
  State<SetName> createState() => _SetNameState();
}

class _SetNameState extends State<SetName> {
  final _textEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _auth = Auth();

  Future<void> preLoadName() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(_auth.user!.uid)
        .get();
    String name = (snapshot.data() as Map<String, dynamic>)['name'] ??
        _auth.user!.displayName ?? '';

    setState(() {
      _textEditingController.text = name;
    });
  }

  @override
  void initState() {
    super.initState();
    preLoadName();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Wie heißt du?'),
          Form(
            key: _formKey,
            child: TextFormField(
              decoration: const InputDecoration(labelText: 'Name'),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Bitte gib deinen Namen ein.';
                }
                return null;
              },
              controller: _textEditingController,
            ),
          ),
          ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  //TODO handle data
                  newNameProvider = Provider<String>((ref) => _textEditingController.text);

                  widget.onComplete();
                }
              },
              child: Text(widget.buttonText == ButtonText.doneText ? 'Fertig' : 'Weiter')),
          TextButton(onPressed: () => context.pop(), child: const Text('Abbrechen')),
        ],
      ),
    );
  }
}
