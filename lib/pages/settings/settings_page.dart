import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equipment_app/custom_widgets/custom_dialog.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../firebase/firebase_auth.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("Einstellungen"),
        Card(
          child: StreamBuilder<Object>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(Auth().user!.uid)
                  .snapshots(),
              builder: (context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData || snapshot.hasError) {
                  return const CircularProgressIndicator.adaptive();
                }
                var data = snapshot.data;
                return Column(
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
                    Text('Hallo, ${data['name']}!'),
                    ElevatedButton(onPressed: () {
                      context.pushNamed("setup", queryParameters: {'editValue': 'name'});
                    }, child: const Text('edit name')),
                    ElevatedButton(onPressed: () {
                      context.pushNamed("setup", queryParameters: {'editValue': 'image'});
                    }, child: const Text('edit image')),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(data['email'] ?? 'keine email'),
                        IconButton(
                            onPressed: () async {
                              Clipboard.setData(
                                      ClipboardData(text: Auth().user!.uid))
                                  .then((_) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "Uid in die Zwischenablage kopiert")));
                              });
                            },
                            icon: const Icon(Icons.copy_rounded))
                      ],
                    ),
                    Text(
                      Auth().user!.uid,
                    ),
                  ],
                );
              }),
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
        if (Auth().user!.isAnonymous)
          Card(
            child: Column(
              children: [
                const Text('Synchronisierung'),
                ElevatedButton(
                    onPressed: () {
                      //TODO link accounts
                    },
                    child: const Text('Account verknüpfen')),
              ],
            ),
          ),
        Card(
          child: Column(
            children: [
              const Text('Spenden'),
              ElevatedButton(
                  onPressed: () {
                    //TODO donation
                  },
                  child: const Text('Paypal')),
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
              if (!Auth().user!.isAnonymous)
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
