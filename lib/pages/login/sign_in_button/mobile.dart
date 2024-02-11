// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'stub.dart';

/// Renders a SIGN IN button that calls `handleSignIn` onclick.
Widget buildSignInButton({HandleSignInFn? onPressed}) {
  return _SignInWithGoogleButton(onPressed: onPressed);
}

class _SignInWithGoogleButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _SignInWithGoogleButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 265,
      height: 60,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: FilledButton(
        style: FilledButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black54,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(15),
            textStyle: const TextStyle(fontSize: 17),
            splashFactory: NoSplash.splashFactory),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
                width: 30,
                height: 30,
                child: Image.asset('assets/googleIcon.png')),
            const Padding(
              padding: EdgeInsets.only(left: 20),
              child: Text('Über Google anmelden'),
            ),
          ],
        ),
      ),
    );
  }
}