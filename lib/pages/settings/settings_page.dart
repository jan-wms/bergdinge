import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equipment_app/custom_widgets/custom_dialog.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../firebase/firebase_auth.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Einstellungen"),
        Card(
          child: Column(
            children: [
              FutureBuilder(
                  future: FirebaseStorage.instance
                      .ref()
                      .child("users/${Auth().user!.uid}/profile.jpg")
                      .getData(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError || !snapshot.hasData) {
                      return Text(snapshot.error.toString());
                    }

                    return CircleAvatar(
                      radius: 48,
                      backgroundImage: Image.memory(snapshot.data!).image,
                    );
                  }),
              FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection("users")
                      .doc(Auth().user!.uid)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError || !snapshot.hasData) {
                      return const CircularProgressIndicator.adaptive();
                    }
                    final DocumentSnapshot<Map<String, dynamic>> data =
                        snapshot.data!;
                    return Text(data['name']);
                  }),

              FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection("users")
                      .doc(Auth().user!.uid)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError || !snapshot.hasData) {
                      return const CircularProgressIndicator.adaptive();
                    }
                    final DocumentSnapshot<Map<String, dynamic>> data =
                    snapshot.data!;
                    return Text(data['email']);
                  }),
              if (Auth().user!.isAnonymous)
                ElevatedButton(
                    onPressed: () {
                      context.go('/link_accounts');
                    },
                    child: const Text('Account erstellen')),
              Text(
                Auth().user!.uid,
              ),
            ],
          ),
        ),
        Card(
          child: Column(
            children: [
              const Text('Kontakt'),
              const Text('appentwicklung.jan@gmx.de'),
              const Text('wermeckes.com'),
              ElevatedButton(
                  onPressed: () {
                    showAboutDialog(context: context);
                  },
                  child: const Text('Über diese App')),
            ],
          ),
        ),
        Card(
          child: Column(
            children: [
              ElevatedButton(
                  onPressed: () {
                    CustomDialog.showCustomConfirmationDialog(
                            context: context,
                            description: 'Account wirklich löschen?')
                        .then((result) async {
                      if (result) {
                        //TODO test delete account, reauthenticate
                        await FirebaseStorage.instance
                            .ref("users/${Auth().user!.uid}")
                            .listAll()
                            .then((value) {
                          for (var element in value.items) {
                            FirebaseStorage.instance
                                .ref(element.fullPath)
                                .delete();
                          }
                        });
                        FirebaseFirestore.instance
                            .collection("users")
                            .doc(Auth().user?.uid)
                            .delete();
                        await Auth().user?.delete();
                      }
                    });
                  },
                  child: const Text('Account löschen')),
              ElevatedButton(
                  onPressed: () {
                    Auth().signOut();
                  },
                  child: const Text('sign out')),
            ],
          ),
        ),
      ],
    );
  }
}
