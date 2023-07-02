import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equipment_app/custom_widgets/custom_dialog.dart';
import 'package:equipment_app/data/providers.dart';
import 'package:equipment_app/pages/introduction/login_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yaml/yaml.dart';

import '../../firebase/firebase_auth.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(userDataStreamProvider).value;
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
              Text('Hallo, ${userData?['name']}!'),
              ElevatedButton(
                  onPressed: () {
                    context.pushNamed("setup",
                        queryParameters: {'editValue': 'name'});
                  },
                  child: const Text('edit name')),
              ElevatedButton(
                  onPressed: () {
                    context.pushNamed("setup",
                        queryParameters: {'editValue': 'image'});
                  },
                  child: const Text('edit image')),
              ElevatedButton(
                  onPressed: () async {
                    await FirebaseStorage.instance
                        .ref("users/${Auth().user!.uid}")
                        .child('profile.jpg')
                        .delete()
                        .then(
                          (value) => FirebaseFirestore.instance
                              .collection("users")
                              .doc(Auth().user?.uid)
                              .update({
                            "profilePicture": FieldValue.delete(),
                          }).then((value) =>
                                  CustomDialog.showCustomInformationDialog(
                                      context: context,
                                      description: 'Profilbild gelöscht.')),
                        );
                  },
                  child: const Text('delete image')),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(Auth().user!.email ?? 'keine email'),
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
        Card(
          child: Column(
            children: [
              const Text('Kontakt'),
              const Text('appentwicklung.jan@gmx.de'),
              const Text('bergdinge.de'),
              FutureBuilder(
                  future: rootBundle.loadString("pubspec.yaml"),
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    String version = "0.0.0";

                    if (snapshot.hasData) {
                      Map yamlData = loadYaml(snapshot.data);
                      version = yamlData["version"];
                    }
                    return Text('Version: $version');
                  }),
              ElevatedButton(
                  onPressed: () {
                    showAboutDialog(
                        context: context,
                        applicationName: 'Bergdinge',
                        applicationVersion: 'Version 1.0.0');
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
                    onPressed: () async {
                      //TODO link accounts
                      CustomDialog.showCustomModal(
                              context,
                              const LoginScreen(authenticationAction: AuthenticationAction.linkAccounts),
                              Container(),
                              IconButton(
                                  onPressed: () => context.pop(),
                                  icon: const Icon(Icons.close)))
                          .then((value) =>
                              CustomDialog.showCustomInformationDialog(
                                  context: context,
                                  description: 'acc verlinkt'));
                    },
                    child: const Text('Account verknüpfen')),
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
                        //TODO test delete account, reauthenticate, delete collections
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
