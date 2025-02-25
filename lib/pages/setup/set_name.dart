import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bergdinge/firebase/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/design.dart';

enum ButtonText { continueText, doneText }

class SetName extends StatefulWidget {
  final ButtonText buttonText;
  final ValueSetter<String> onComplete;

  const SetName(
      {super.key, required this.buttonText, required this.onComplete});

  @override
  State<SetName> createState() => _SetNameState();
}

class _SetNameState extends State<SetName> {
  final _textEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _auth = Auth();

  Future<void> preLoadName() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(_auth.user!.uid)
          .get();
      String name = (snapshot.data() as Map<String, dynamic>)['name'] ??
          _auth.user!.displayName ??
          '';

      setState(() {
        _textEditingController.text = name;
      });
    } catch (e) {
      //could not preload name
    }
  }

  @override
  void initState() {
    super.initState();
    preLoadName();
  }

  @override
  void dispose() {
    super.dispose();
    _textEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: Design.pagePadding.copyWith(bottom: 40.0, top: 50.0),
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
            Container(
              constraints: const BoxConstraints(
                maxWidth: 400.0,
              ),
              child: Form(
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
            ),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 400.0,
              ),
              padding: const EdgeInsets.only(top: 50.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: MediaQuery.of(context).size.width > Design.breakpoint1 ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                children: [
                  if(context.canPop())
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
                          backgroundColor: Design.colors[1],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0))),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          widget.onComplete(_textEditingController.text);
                        }
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: 30,
                        width: 105,
                        child: Text(
                          widget.buttonText == ButtonText.doneText
                              ? 'Fertig'
                              : 'Weiter',
                          style: const TextStyle(fontSize: 17),
                        ),
                      ))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
