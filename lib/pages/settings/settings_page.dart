import 'package:dismissible_page/dismissible_page.dart';
import 'package:equipment_app/custom_widgets/custom_appbar.dart';
import 'package:equipment_app/data/design.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equipment_app/custom_widgets/custom_dialog.dart';
import 'package:equipment_app/data/providers.dart';
import 'package:equipment_app/pages/setup/setup_screen.dart';
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
            child: const Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                    width: 30.0,
                    height: 30.0,
                    child: CircularProgressIndicator()),
              ],
            ));

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
                  title: 'Hallo${(userData?['name'] == null || userData?['name'] == 'null' || (userData?['name']).toString().isEmpty) ? '' : ' ${userData?['name']}'}!' ,
                  icon: Icons.person_rounded,
                  buttonIcon: Icons.edit_rounded,
                  onButtonPressed: () {
                    CustomDialog.showCustomModal(
                    context: context,
                    child: SetupScreen(editValue: EditValue.name),
                  );
                  },
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      Container(
                        margin: Design.pagePadding.copyWith(top: 20.0),
                        decoration: BoxDecoration(
                          color: (firebaseUser?.isAnonymous ?? false)
                              ? const Color.fromRGBO(246, 236, 202, 1.0)
                              : (ref.read(authProvider) == 'apple.com')
                                  ? Colors.white
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
                                  : _DisplayAuthProvider(
                                      email: firebaseUser?.email,
                                      authProvider: ref.read(authProvider),
                                    ),
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
                            _CustomListTile(
                              title: Data.websiteUrlShort,
                              icon: Icons.launch_rounded,
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
                            ),
                            _CustomListTile(
                              title: Data.supportMail,
                              icon: Icons.mail_outline_rounded,
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
                                  query: encodeQueryParameters(<String, String>{
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
                            ),
                            _CustomListTile(
                              title: 'Unterstützen',
                              icon: Icons.favorite_outline_rounded,
                              onTap: () =>
                                  CustomDialog.showCustomInformationDialog(
                                      context: context,
                                      description:
                                          'Diese Funktion ist nicht verfügbar.'),
                            ),
                            const Padding(padding: EdgeInsets.only(top: 30.0)),
                            _CustomListTile(
                              title: 'UID kopieren',
                              onTap: () {
                                copyToClipboard(
                                    context: context,
                                    value:
                                        Auth().user?.uid ?? 'uid not provided');
                              },
                              icon: Icons.copy_rounded,
                            ),
                            _CustomListTile(
                              title: 'Lizenzen',
                              icon: Icons.arrow_forward_rounded,
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

class _CustomListTile extends StatelessWidget {
  final String title;
  final IconData? icon;
  final VoidCallback onTap;

  const _CustomListTile({required this.title, this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: ListTile(
          title: Text(title),
          trailing: Icon(icon),
        ), // ListTile
      ), // InkWell
    );
  }
}

class _DisplayAuthProvider extends StatelessWidget {
  final String? email;
  final String authProvider;

  const _DisplayAuthProvider({this.email, required this.authProvider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: (authProvider == 'apple.com') ? Colors.black : Colors.white,
        boxShadow: (authProvider == 'apple.com')
            ? null
            : [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          (authProvider == 'apple.com')
              ? const Icon(
                  IconData(0xf02d8, fontFamily: 'MaterialIcons'),
                  size: 30,
                  color: Colors.white,
                )
              : SizedBox(
                  width: 30,
                  height: 30,
                  child: Image.asset('assets/googleIcon.png')),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                email ??
                    ((authProvider == 'apple.com')
                        ? 'Mit Apple angemeldet'
                        : 'Über Google angemeldet'),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  color: (authProvider == 'apple.com')
                      ? Colors.white
                      : Colors.black54,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
