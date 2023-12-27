import 'package:equipment_app/data/design.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equipment_app/custom_widgets/custom_dialog.dart';
import 'package:equipment_app/data/providers.dart';
import 'package:equipment_app/pages/introduction/setup_screen.dart';
import 'package:equipment_app/pages/login/login_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yaml/yaml.dart';

import '../../data/data.dart';
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

  void copyToClipboard(
      {required BuildContext context, required String value}) async {
    Clipboard.setData(ClipboardData(text: value)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("In die Zwischenablage kopiert"),
      ));
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(userDataStreamProvider).value;
    final firebaseUser = ref.watch(userChangesProvider).value;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: ListView(
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Design.colors[0],
                borderRadius: const BorderRadius.all(Radius.circular(20.0)),
              ),
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Hallo ${userData?['name']}!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 35,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          CustomDialog.showCustomModal(
                            context: context,
                            child: SetupScreen(editValue: EditValue.name),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(7)),
                        child: const Icon(Icons.edit_rounded),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            copyToClipboard(
                                context: context, value: Auth().user!.uid);
                          },
                          icon: const Icon(
                            Icons.copy_rounded,
                            size: 20,
                            color: Color.fromRGBO(210, 210, 210, 1),
                          )),
                      Text(
                        Auth().user?.uid ?? 'no uid provided',
                        style: const TextStyle(
                          color: Color.fromRGBO(210, 210, 210, 1),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!(firebaseUser?.isAnonymous ?? true))
              Container(
                margin: const EdgeInsets.only(top: 20),
                decoration: const BoxDecoration(
                  //color: Design.colors[4],
                  color: (1 == 1)
                      ? Color.fromRGBO(246, 236, 202, 1.0)
                      : Color.fromRGBO(172, 236, 161, 1.0),
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                ),
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    (1 == 1)
                        ? const Icon(
                            Icons.warning_rounded,
                            color: Color.fromRGBO(189, 166, 57, 1.0),
                            size: 50,
                          )
                        : const Icon(
                            Icons.check_circle_outline_rounded,
                            color: Colors.green,
                            size: 50,
                          ),
                    const Text('Synchronisierung aktiviert'),
                    Text(ref.read(authProvider)),
                  ],
                ),
              ),
            Text(firebaseUser?.email ?? 'keine email'),

            if (firebaseUser?.isAnonymous ?? false)
              Card(
                child: Column(
                  children: [
                    const Text('Synchronisierung'),
                    ElevatedButton(
                        onPressed: () async {
                          CustomDialog.showCustomModal(
                            context: context,
                            child: LoginScreen(
                                onComplete: () {
                                  context.pop();
                                  CustomDialog.showCustomInformationDialog(
                                      context: context,
                                      description: 'acc verlinkt');
                                },
                                authenticationAction:
                                    AuthenticationAction.linkAccounts),
                          );
                        },
                        child: const Text('Account verknüpfen')),
                  ],
                ),
              ),
            const Text('Kontakt'),
            TextButton(
                onPressed: () async {
                  String? encodeQueryParameters(Map<String, String> params) {
                    return params.entries
                        .map((MapEntry<String, String> e) =>
                            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
                        .join('&');
                  }

                  final Uri uri = Uri(
                    scheme: 'mailto',
                    path: Data.supportMail,
                    query: encodeQueryParameters(<String, String>{
                      'subject': 'Bergdinge',
                    }),
                  );

                  launchUrl(uri).then((didLaunch) {
                    if (didLaunch == false) {
                      copyToClipboard(
                          context: context, value: Data.supportMail);
                    }
                  });
                },
                child: Text(Data.supportMail)),
            TextButton(
                onPressed: () async {
                  final Uri url = Uri.parse(Data.websiteUrl);
                  launchUrl(url).then((didLaunch) {
                    if (didLaunch == false) {
                      copyToClipboard(context: context, value: Data.websiteUrl);
                    }
                  });
                },
                child: Text(Data.websiteUrlShort)),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                    onPressed: () async {
                      if (Auth().user!.isAnonymous) {
                        deleteAccount(context);
                      } else {
                        await CustomDialog.showCustomModal(
                          context: context,
                          child: LoginScreen(
                              onComplete: () {
                                context.pop();
                                deleteAccount(context);
                              },
                              authenticationAction:
                                  AuthenticationAction.reauthenticate),
                        );
                      }
                    },
                    child: const Text(
                      'Account löschen',
                      style: TextStyle(color: Colors.red),
                    )),
                if (!(firebaseUser?.isAnonymous ?? true))
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.red,
                        backgroundColor: const Color.fromRGBO(253, 215, 215, 1.0),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                      ),
                      onPressed: () {
                        Auth().signOut();
                      },
                      child: const Text('Abmelden')),
              ],
            ),
            const Divider(),
            FutureBuilder(
                future: rootBundle.loadString("pubspec.yaml"),
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  String version = "0.0.0";

                  if (snapshot.hasData) {
                    Map yamlData = loadYaml(snapshot.data);
                    version = yamlData["version"];
                  }
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      /*TextButton(
                          onPressed: () => showLicensePage(context: context),
                          child: const Text('show licenses')),*/
                      Text(
                        'Bergdinge Version $version ❤️',
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  );
                }),
            //TODO remove in production
            /*ElevatedButton(
                onPressed: () => CustomDialog.showCustomInformationDialog(
                    context: context, description: 'description'),
                child: const Text('information')),
            ElevatedButton(
                onPressed: () => CustomDialog.showCustomConfirmationDialog(
                    context: context, description: 'description'),
                child: const Text('confirmation')),*/
          ],
        ),
      ),
    );
  }
}
