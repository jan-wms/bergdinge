import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final authProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.userChanges();
});

enum AuthenticationAction {
  signIn,
  linkAccounts,
  reauthenticate,
}

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

  StreamSubscription gsiOnCurrentUserChanged({
    required AuthenticationAction authenticationAction,
  }) {
    late final StreamSubscription<GoogleSignInAccount?> gsiUserChanged;
    final StreamController streamController = StreamController(onCancel: () {
      gsiUserChanged.cancel();
    });

    gsiUserChanged = _googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount? account) async {
      if (account != null) {
        streamController.add(account);
        try {
          final GoogleSignInAuthentication gAuth = await account.authentication;
          final credential = GoogleAuthProvider.credential(
            accessToken: gAuth.accessToken,
            idToken: gAuth.idToken,
          );

          if (authenticationAction == AuthenticationAction.linkAccounts) {
            print('link acc');
            await _firebaseAuth.currentUser?.linkWithCredential(credential);
          } else if (authenticationAction == AuthenticationAction.reauthenticate) {
            print('reauthenticate');
            await _firebaseAuth.currentUser?.reauthenticateWithCredential(credential);
          } else {
            print('new acc');
            await _firebaseAuth.signInWithCredential(credential);
          }
        } on FirebaseAuthException catch (error) {
          debugPrint(error.toString());
          streamController.addError(error);
        }
      }
    });

    return streamController.stream.listen((event) {});
  }

  Future<void> signInWithGoogle() async {
    try {
      await _googleSignIn.signIn();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
