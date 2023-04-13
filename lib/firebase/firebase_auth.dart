import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final authProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
    ],
  );

  User? get user => _firebaseAuth.currentUser;

  Future<void> signInAnonymously() async {
    await _firebaseAuth.signInAnonymously();
  }

  Future<GoogleSignInAccount?> googleSignInSilently() async {
    return await _googleSignIn.signInSilently();
  }

  Object gsiOnCurrentUserChanged({
    required bool isLinkingAccounts,
  }) {
      return _googleSignIn.onCurrentUserChanged
          .listen((GoogleSignInAccount? account) async {
        if (account != null) {
          try {
            final GoogleSignInAuthentication gAuth =
                await account.authentication;
            final credential = GoogleAuthProvider.credential(
              accessToken: gAuth.accessToken,
              idToken: gAuth.idToken,
            );

            if (isLinkingAccounts) {
              await _firebaseAuth.currentUser?.linkWithCredential(credential);
            } else {
              await _firebaseAuth.signInWithCredential(credential);
            }
          } on FirebaseAuthException catch (e) {
            debugPrint(e.toString());
          }
        }
      });
  }

  Future<void> signInWithGoogle() async {
    try {
      await _googleSignIn.signIn();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
    required bool isLinkingAccounts,
  }) async {
    if (isLinkingAccounts) {
      final credential =
          EmailAuthProvider.credential(email: email, password: password);
      await _firebaseAuth.currentUser?.linkWithCredential(credential);
    } else {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    }
  }

  Future<void> sendEmailVerification() async {
    await FirebaseAuth.instance.setLanguageCode("de");
    await FirebaseAuth.instance.currentUser?.sendEmailVerification();
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
