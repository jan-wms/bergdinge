import 'dart:async';

import 'package:equipment_app/firebase/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({Key? key}) : super(key: key);

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  late Timer timer;
  bool isEmailVerified = false;

  Future<void> sendEmailVerification() async {
    try {
      await Auth().sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      print(e);
    }
  }

  checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser?.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) {
      timer.cancel();
      await Future.delayed(const Duration(seconds: 2)).then((value) => context.go('/'));
    }
  }


  @override
  void initState() {
    super.initState();
    sendEmailVerification();
    timer =
        Timer.periodic(const Duration(seconds: 3), (_) => checkEmailVerified());
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isEmailVerified ? const Icon(Icons.check_circle_rounded) : Column(
          children: [
             Text('Verify Email ${Auth().user?.email}'),
            const Center(child: CircularProgressIndicator()),
            ElevatedButton(
              child: const Text('Resend'),
              onPressed: () => sendEmailVerification(),
            ),
          ],
        ),
      ),
    );
  }
}


