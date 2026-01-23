import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final userChangesProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.userChanges();
});

enum AuthenticationAction {
  signIn,
  linkAccounts,
  reauthenticate,
}

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  User? get user => _firebaseAuth.currentUser;

  Future<UserCredential> signInAnonymously() async {
    return await _firebaseAuth.signInAnonymously();
  }

  Future<UserCredential?> signInWithGoogle(
      {required AuthenticationAction authenticationAction}) async {
    // On Web
    if(kIsWeb) {
      final provider = GoogleAuthProvider();
      switch (authenticationAction) {
        case AuthenticationAction.signIn:
          return await _firebaseAuth.signInWithPopup(provider);
        case AuthenticationAction.linkAccounts:
          return await _firebaseAuth.currentUser?.linkWithPopup(provider);
        case AuthenticationAction.reauthenticate:
          return await _firebaseAuth.currentUser
              ?.reauthenticateWithPopup(provider);
      }
    }

    // On iOS or Android
    _googleSignIn.initialize(serverClientId: "431093041285-d6cjl21t18fg1dvih1tkgeauhtlcif53.apps.googleusercontent.com");

    final GoogleSignInAccount account = await _googleSignIn.authenticate();
    final GoogleSignInAuthentication auth = account.authentication;
    final OAuthCredential credential =
        GoogleAuthProvider.credential(idToken: auth.idToken);

    switch (authenticationAction) {
      case AuthenticationAction.signIn:
        return await _firebaseAuth.signInWithCredential(credential);
      case AuthenticationAction.linkAccounts:
        return await _firebaseAuth.currentUser?.linkWithCredential(credential);
      case AuthenticationAction.reauthenticate:
        return await _firebaseAuth.currentUser
            ?.reauthenticateWithCredential(credential);
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}
