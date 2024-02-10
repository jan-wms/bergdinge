import 'package:equipment_app/custom_widgets/custom_appbar.dart';
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

import '../../copy_to_clipboard.dart';
import '../../data/data.dart';
import '../../firebase/firebase_auth.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  void deleteAccount(BuildContext context) {
    CustomDialog.showCustomConfirmationDialog(
            type: ConfirmType.confirmDelete,
            context: context,
            description: 'Möchtest du deinen Account wirklich löschen?')
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

    return SafeArea(
      top: false,
      child: FutureBuilder(
          future: rootBundle.loadString("pubspec.yaml"),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            String version = "0.0.0";

            if (snapshot.hasData) {
              Map yamlData = loadYaml(snapshot.data);
              version = yamlData["version"];
            }
            return CustomScrollView(
              slivers: [
                CustomAppBar(
                  title: 'Hallo ${userData?['name']}!',
                  icon: Icons.person_rounded,
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      if (false)
                        Container(
                          margin: Design.pagePadding.copyWith(top: 20.0),
                          height: 200,
                          decoration: BoxDecoration(
                            color: Design.colors[0],
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20.0)),
                          ),
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'lkjb',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 35,
                                        ),
                                      ),
                                      Text(
                                        firebaseUser?.email ?? '',
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  FilledButton(
                                    onPressed: () {
                                      CustomDialog.showCustomModal(
                                        context: context,
                                        child: SetupScreen(
                                            editValue: EditValue.name),
                                      );
                                    },
                                    style: FilledButton.styleFrom(
                                      foregroundColor: Design.colors[0],
                                      backgroundColor: Colors.white,
                                      shape: const CircleBorder(),
                                    ),
                                    child: const Icon(
                                      Icons.edit_rounded,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        copyToClipboard(
                                            context: context,
                                            value: Auth().user!.uid);
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
                      Container(
                        margin: Design.pagePadding.copyWith(top: 20.0),
                        decoration: BoxDecoration(
                          color: (firebaseUser?.isAnonymous ?? false)
                              ? const Color.fromRGBO(246, 236, 202, 1.0)
                              : Design.colors[7],
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20.0)),
                          boxShadow: [
                            if (!(firebaseUser?.isAnonymous ?? true))
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 4,
                                blurRadius: 10,
                                offset: const Offset(2, 3),
                              ),
                          ],
                        ),
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                (firebaseUser?.isAnonymous ?? false)
                                    ? Icon(
                                        Icons.warning_rounded,
                                        color: Design.colors[6],
                                        size: 50,
                                      )
                                    : const Icon(
                                        Icons.check_circle_outline_rounded,
                                        color: Colors.green,
                                        size: 50,
                                      ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Synchronisierung',
                                          style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 25,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        Text(
                                          (firebaseUser?.isAnonymous ?? false)
                                              ? 'Melde dich an, um Bergdinge auf mehreren Geräten zu benutzen.'
                                              : 'Cloud-Synchronisierung ist aktiviert.',
                                          style: const TextStyle(
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 30.0),
                              child: (firebaseUser?.isAnonymous ?? false)
                                  ? ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          backgroundColor: Design.colors[6],
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0))),
                                      onPressed: () async {
                                        CustomDialog.showCustomModal(
                                          context: context,
                                          child: LoginScreen(
                                              onComplete: () {
                                                context.pop();
                                                CustomDialog
                                                    .showCustomInformationDialog(
                                                        context: context,
                                                        description:
                                                            'acc verlinkt');
                                              },
                                              authenticationAction:
                                                  AuthenticationAction
                                                      .linkAccounts),
                                        );
                                      },
                                      child: const Text('Aktivieren'))
                                  : Text(ref.read(authProvider)),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(15.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 4,
                              blurRadius: 10,
                              offset: const Offset(2, 3),
                            ),
                          ],
                        ),
                        margin: Design.pagePadding
                            .copyWith(top: 25.0, bottom: 30.0),
                        child: Column(
                          children: [
                            ListTile(
                                onTap: () async {
                                  String? encodeQueryParameters(
                                      Map<String, String> params) {
                                    return params.entries
                                        .map((MapEntry<String, String> e) =>
                                            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
                                        .join('&');
                                  }

                                  final Uri uri = Uri(
                                    scheme: 'mailto',
                                    path: Data.supportMail,
                                    query:
                                        encodeQueryParameters(<String, String>{
                                      'subject': 'Bergdinge',
                                    }),
                                  );

                                  launchUrl(uri).then((didLaunch) {
                                    if (didLaunch == false) {
                                      copyToClipboard(
                                          context: context,
                                          value: Data.supportMail);
                                    }
                                  });
                                },
                                trailing:
                                    const Icon(Icons.mail_outline_rounded),
                                title: Text(Data.supportMail)),
                            ListTile(
                                onTap: () async {
                                  final Uri url = Uri.parse(Data.websiteUrl);
                                  launchUrl(url).then((didLaunch) {
                                    if (didLaunch == false) {
                                      copyToClipboard(
                                          context: context,
                                          value: Data.websiteUrl);
                                    }
                                  });
                                },
                                trailing: const Icon(Icons.launch_rounded),
                                title: Row(
                                  children: [
                                    Text(Data.websiteUrlShort),
                                  ],
                                )),
                            const ListTile(
                              title: Text('Test'),
                            ),
                            InkWell(
                              onTap: () {},
                              child: const ListTile(
                                title: Text('Test1'),
                              ),
                            ),
                            const ListTile(
                              title: Text('Test'),
                            ),
                            const ListTile(
                              title: Text('Test'),
                            ),
                            ListTile(
                              title: const Text('Lizenzen'),
                              trailing: const Icon(Icons.chevron_right_rounded),
                              onTap: () => showLicensePage(
                                  context: context,
                                  applicationName: 'Bergdinge',
                                  applicationVersion: version,
                                  useRootNavigator: true),
                            ),
                          ],
                        ),
                      ),
                      if (!(firebaseUser?.isAnonymous ?? true))
                        Container(
                          margin: const EdgeInsets.only(
                              left: 50.0, right: 50.0, bottom: 15.0),
                          child: TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                                backgroundColor:
                                    const Color.fromRGBO(255, 222, 222, 1.0),
                                shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                              ),
                              onPressed: () {
                                Auth().signOut();
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.logout_rounded),
                                  Padding(
                                    padding: EdgeInsets.only(left: 10.0),
                                    child: Text(
                                      'Abmelden',
                                      style: TextStyle(fontSize: 17),
                                    ),
                                  ),
                                ],
                              )),
                        ),
                      Container(
                        margin: const EdgeInsets.only(left: 50.0, right: 50.0),
                        child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor:
                                  const Color.fromRGBO(255, 194, 194, 1.0),
                              side: const BorderSide(color: Colors.red),
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                            ),
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
                              style: TextStyle(color: Colors.red, fontSize: 17),
                            )),
                      ),
                      Padding(
                        padding: Design.pagePadding.copyWith(top: 20.0),
                        child: const Divider(),
                      ),
                      Container(
                        margin: Design.pagePadding.copyWith(bottom: 50.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              'Bergdinge Version $version️',
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
    );
  }
}
