import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equipment_app/custom_widgets/custom_dialog.dart';
import 'package:equipment_app/data/providers.dart';
import 'package:equipment_app/pages/introduction/login_screen.dart';
import 'package:equipment_app/pages/introduction/setup_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yaml/yaml.dart';

import '../../firebase/firebase_auth.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  void deleteAccount(BuildContext context) {
    CustomDialog.showCustomConfirmationDialog(
            context: context, description: 'Account wirklich löschen?')
        .then((result) async {
      if (result) {
        CustomDialog.showCustomDialog(
            context: context,
            child: const CircularProgressIndicator.adaptive());

        ///FirebaseStorage (e.g. profile picture)
        await FirebaseStorage.instance
            .ref("users/${Auth().user!.uid}")
            .listAll()
            .then((value) {
          for (var element in value.items) {
            FirebaseStorage.instance.ref(element.fullPath).delete();
          }
        });

        ///Firestore
        DocumentReference userDoc = FirebaseFirestore.instance
            .collection('users')
            .doc(Auth().user?.uid);

        //user collections ==> timeout??
        List<CollectionReference> collectionsToDelete = [
          userDoc.collection('packing_plan'),
          userDoc.collection('equipment'),
        ];

        for (var collection in collectionsToDelete) {
          collection.get().then((snapshot) {
            for (var doc in snapshot.docs) {
              doc.reference.delete();
            }
          });
        }

        //user document
        await userDoc.delete();

        ///FirebaseAuth
        await Auth().user?.delete();
      }
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(userDataStreamProvider).value;
    final firebaseUser = ref.watch(userChangesProvider).value;

    return Column(
      children: [
        const Text("Einstellungen"),
        Card(
          child: Column(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundImage: ref.watch(profilePictureStreamProvider).value,
              ),
              Text('Hallo ${userData?['name']}!'),
              ElevatedButton(
                  onPressed: () {
                    CustomDialog.showCustomModal(
                        context,
                        const SetupScreen(editValue: 'name'),
                        Container(),
                        IconButton(
                            onPressed: () => context.pop(),
                            icon: const Icon(Icons.close)));
                  },
                  child: const Text('edit name')),
              ElevatedButton(
                  onPressed: () {
                    context.pushNamed("setup",
                        queryParameters: {'editValue': 'image'});
                  },
                  child: const Text('edit image')),
              if (userData?['profilePicture'] != null)
                ElevatedButton(
                    onPressed: () async {
                      CustomDialog.showCustomConfirmationDialog(
                              context: context,
                              description:
                                  'Möchtest du dein Profilbild wirklich löschen?')
                          .then((value) {
                        if (value) {
                          FirebaseStorage.instance
                              .ref("users/${Auth().user!.uid}")
                              .child('profile.jpg')
                              .delete()
                              .then((value) => FirebaseFirestore.instance
                                      .collection("users")
                                      .doc(Auth().user?.uid)
                                      .update({
                                    "profilePicture": FieldValue.delete(),
                                  }));
                        }
                      });
                    },
                    child: const Text('delete image')),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(firebaseUser?.email ?? 'keine email'),
                  IconButton(
                      onPressed: () async {
                        Clipboard.setData(ClipboardData(text: Auth().user!.uid))
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
          ),
        ),
        FutureBuilder(
            future: rootBundle.loadString("pubspec.yaml"),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              String version = "0.0.0";

              if (snapshot.hasData) {
                Map yamlData = loadYaml(snapshot.data);
                version = yamlData["version"];
              }
              return Card(
                child: Column(
                  children: [
                    const Text('Kontakt'),
                    const Text('appentwicklung.jan@gmx.de'),
                    const Text('bergdinge.de'),
                    Text('Version: $version'),
                    ElevatedButton(
                        onPressed: () {
                          showAboutDialog(
                              context: context,
                              applicationName: 'Bergdinge',
                              applicationVersion: 'Version $version');
                        },
                        child: const Text('Über diese App')),
                  ],
                ),
              );
            }),
        if (firebaseUser!.isAnonymous)
          Card(
            child: Column(
              children: [
                const Text('Synchronisierung'),
                ElevatedButton(
                    onPressed: () async {
                      CustomDialog.showCustomModal(
                          context,
                          LoginScreen(
                              onComplete: () {
                                context.pop();
                                CustomDialog.showCustomInformationDialog(
                                    context: context,
                                    description: 'acc verlinkt');
                              },
                              authenticationAction:
                                  AuthenticationAction.linkAccounts),
                          Container(),
                          IconButton(
                              onPressed: () => context.pop(),
                              icon: const Icon(Icons.close)));
                    },
                    child: const Text('Account verknüpfen')),
              ],
            ),
          ),
        if (!firebaseUser.isAnonymous)
          const Card(
            child: Column(
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  color: Colors.green,
                ),
                Text('Synchronisierung aktiviert'),
              ],
            ),
          ),
        Card(
          child: Column(
            children: [
              ElevatedButton(
                  onPressed: () async {
                    if (Auth().user!.isAnonymous) {
                      deleteAccount(context);
                    } else {
                      await CustomDialog.showCustomModal(
                          context,
                          LoginScreen(
                              onComplete: () {
                                context.pop();
                                deleteAccount(context);
                              },
                              authenticationAction:
                                  AuthenticationAction.reauthenticate),
                          Container(),
                          IconButton(
                              onPressed: () => context.pop(),
                              icon: const Icon(Icons.close)));
                    }
                  },
                  child: const Text('Account löschen')),
              if (!firebaseUser.isAnonymous)
                ElevatedButton(
                    onPressed: () {
                      Auth().signOut();
                    },
                    child: const Text('Abmelden')),
            ],
          ),
        ),
      ],
    );
  }
}
