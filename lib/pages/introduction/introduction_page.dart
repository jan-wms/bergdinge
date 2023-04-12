import 'package:equipment_app/firebase/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';

import 'login_screen.dart';

class IntroductionPage extends StatefulWidget {
  const IntroductionPage({Key? key}) : super(key: key);

  @override
  State<IntroductionPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage> {
  final _pageController = PageController(initialPage: 0);
  final _formKey = GlobalKey<FormState>();
  final _textFieldController =
      TextEditingController(text: Auth().user?.displayName);
  var a = Auth().user?.photoURL;
  ScrollPhysics _scrollPhysics = const PageScrollPhysics();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: PageView(
      physics: _scrollPhysics,
      controller: _pageController,
      children: [
        Container(
          color: Colors.black12,
          child: const Center(
            child: Text('Herzlich willkommen!'),
          ),
        ),
        LoginScreen(
          onWaitingEnd: () => setState(() {
            _scrollPhysics = const PageScrollPhysics();
          }),
          onWaitingStart: () => setState(() {
            _scrollPhysics = const NeverScrollableScrollPhysics();
          }),
        ),
       /* Center(
          child: Column(
            children: [
              if (a != null)
                ImageNetwork(
                  image: a!,
                  height: 200,
                  width: 200,
                ),
              const Text('Wie heißt du?'),
              Form(
                key: _formKey,
                child: TextFormField(
                  decoration: const InputDecoration(labelText: 'Vorname'),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Bitte einen gültigen Namen eingeben.';
                    }
                    return null;
                  },
                  controller: _textFieldController,
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {}
                  },
                  child: const Text('Weiter'))
            ],
          ),
        ),*/
      ],
    ));
  }
}
