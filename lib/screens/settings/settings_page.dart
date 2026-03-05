import 'package:bergdinge/data/design.dart';
import 'package:bergdinge/screens/settings/attribution.dart';
import 'package:bergdinge/widgets/custom_dialog.dart';
import 'package:bergdinge/firebase/firebase_data_providers.dart';
import 'package:bergdinge/screens/setup/setup_screen.dart';
import 'package:bergdinge/screens/auth/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yaml/yaml.dart';

import '../../router/app_state_provider.dart';
import '../../firebase/firebase_auth.dart';
import '../../widgets/custom_sliver_app_bar.dart';
import 'display_auth_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = MediaQuery.of(context).size.width > 850;
    final userData = ref.watch(userDataStreamProvider).value;
    final firebaseUser = ref.watch(userChangesProvider).value;

    void deleteAccount(BuildContext context) async {
      bool? result = await CustomDialog.showCustomConfirmationDialog(
          type: ConfirmType.confirmDelete,
          context: context,
          description: 'Möchtest du deinen Account wirklich löschen?');
      if ((result ?? false) && context.mounted) {
        ref.read(appStateProvider.notifier).setLoading();
        await Auth().deleteAccount();
      }
    }

    return FutureBuilder(
        future: rootBundle.loadString("pubspec.yaml"),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          String version = "0.0.0";

          if (snapshot.hasData) {
            Map yamlData = loadYaml(snapshot.data);
            version = yamlData["version"];
          }
          return CustomScrollView(
            slivers: [
              CustomSliverAppBar(

                title:
                    'Hallo${(userData?['name'] == null || userData?['name'] == 'null' || (userData?['name']).toString().isEmpty) ? '' : ' ${userData?['name']}'}!',
                icon: Icons.person_rounded,
                buttonIcon: Icons.edit_rounded,
                onButtonPressed: () {
                  CustomDialog.showCustomModal(
                    isFullscreen: true,
                    context: context,
                    child: SetupScreen(editValue: EditValue.name),
                  );
                },
              ),
              SliverPadding(
                padding: Design.pagePadding.copyWith(top: 30.0),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        fit: FlexFit.loose,
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: (firebaseUser?.isAnonymous ?? false)
                                    ? const Color.fromRGBO(246, 236, 202, 1.0)
                                    : (ref.read(userAuthProvider) ==
                                            'apple.com')
                                        ? Colors.white
                                        : Color.fromRGBO(252, 253, 247, 1.0),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(20.0)),
                                boxShadow: [
                                  if (!(firebaseUser?.isAnonymous ?? true))
                                    BoxShadow(
                                      color: Colors.grey.withValues(alpha: 0.2),
                                      spreadRadius: 4,
                                      blurRadius: 10,
                                      offset: const Offset(2, 3),
                                    ),
                                ],
                              ),
                              constraints: const BoxConstraints(
                                maxWidth: 450.0,
                              ),
                              padding: const EdgeInsets.all(15.0),
                              margin: const EdgeInsets.only(bottom: 15.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      (firebaseUser?.isAnonymous ?? false)
                                          ? Icon(
                                              Icons.warning_rounded,
                                              color: Color.fromRGBO(
                                                  189, 166, 57, 1.0),
                                              size: 50,
                                            )
                                          : const Icon(
                                              Icons
                                                  .check_circle_outline_rounded,
                                              color: Colors.green,
                                              size: 50,
                                            ),
                                      Flexible(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10.0),
                                          child: Text(
                                            (firebaseUser?.isAnonymous ?? false)
                                                ? 'Melde dich an, um Bergdinge auf mehreren Geräten zu benutzen.'
                                                : 'Cloud-Synchronisierung ist aktiviert.',
                                            style: const TextStyle(
                                                color: Colors.black87,
                                                fontSize: 16.0),
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
                                                backgroundColor: Color.fromRGBO(
                                                    189, 166, 57, 1.0),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0))),
                                            onPressed: () async {
                                              CustomDialog.showCustomModal(
                                                isFullscreen: true,
                                                context: context,
                                                child: ClipRRect(
                                                  borderRadius: (MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width >
                                                          Design
                                                              .wideScreenBreakpoint)
                                                      ? BorderRadius.circular(
                                                          20.0)
                                                      : BorderRadius.zero,
                                                  child: SignInScreen(
                                                      onComplete: () {
                                                        context.pop();
                                                        CustomDialog
                                                            .showCustomInformationDialog(
                                                                context:
                                                                    context,
                                                                description:
                                                                    'Synchronisierung erfolgreich.');
                                                      },
                                                      authenticationAction:
                                                          AuthenticationAction
                                                              .linkAccounts),
                                                ),
                                              );
                                            },
                                            child: const Text('Aktivieren'))
                                        : DisplayAuthProvider(
                                            email: firebaseUser?.email,
                                            authProvider:
                                                ref.read(userAuthProvider),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                            if (!isWide)
                              Container(
                                constraints:
                                    const BoxConstraints(maxWidth: 450.0),
                                padding: const EdgeInsets.only(bottom: 15.0),
                                child: Attribution(
                                  version: version,
                                  spacing: 30.0,
                                ),
                              ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (!(firebaseUser?.isAnonymous ?? true))
                                  Padding(
                                    padding: const EdgeInsets.only(top: 15.0),
                                    child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.only(
                                                left: 20.0,
                                                right: 20.0,
                                                top: 10.0,
                                                bottom: 10.0),
                                            foregroundColor: Colors.white,
                                            backgroundColor: Colors.red,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10.0))),
                                        onPressed: () {
                                          CustomDialog.showCustomConfirmationDialog(
                                                  context: context,
                                                  description:
                                                      'Möchtest du dich abmelden?',
                                                  type: ConfirmType
                                                      .confirmDefault)
                                              .then((value) {
                                            if (value ?? false) {
                                              Auth().signOut();
                                            }
                                          });
                                        },
                                        child: Container(
                                            alignment: Alignment.center,
                                            height: 30,
                                            width: 150,
                                            child: const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.logout_rounded,
                                                  color: Colors.white,
                                                  size: 25,
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 10.0),
                                                  child: Text(
                                                    'Abmelden',
                                                    style:
                                                        TextStyle(fontSize: 17),
                                                  ),
                                                ),
                                              ],
                                            ))),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 15.0),
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color.fromRGBO(
                                          255, 194, 194, 1.0),
                                      side: const BorderSide(color: Colors.red),
                                      padding: const EdgeInsets.only(
                                          left: 20.0,
                                          right: 20.0,
                                          top: 10.0,
                                          bottom: 10.0),
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                    ),
                                    onPressed: () async {
                                      if (Auth().user!.isAnonymous) {
                                        deleteAccount(context);
                                      } else {
                                        await CustomDialog.showCustomModal(
                                          isFullscreen: true,
                                          context: context,
                                          child: ClipRRect(
                                            borderRadius: (MediaQuery.of(
                                                            context)
                                                        .size
                                                        .width >
                                                    Design.wideScreenBreakpoint)
                                                ? BorderRadius.circular(20.0)
                                                : BorderRadius.zero,
                                            child: SignInScreen(
                                                onComplete: () {
                                                  context.pop();
                                                  deleteAccount(context);
                                                },
                                                authenticationAction:
                                                    AuthenticationAction
                                                        .reauthenticate),
                                          ),
                                        );
                                      }
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      height: 30,
                                      width: 150,
                                      child: const Text(
                                        'Account löschen',
                                        style: TextStyle(
                                            color: Colors.red, fontSize: 17),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      if (isWide)
                        const SizedBox(
                          width: 15.0,
                        ),
                      if (isWide)
                        Expanded(
                            child: Attribution(
                          version: version,
                          spacing: 50.0,
                        )),
                    ],
                  ),
                ),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: Design.pagePadding.copyWith(top: 20.0),
                      child: const Divider(),
                    ),
                    Container(
                      margin: Design.pagePadding.copyWith(
                          bottom: 15.0 + MediaQuery.of(context).padding.bottom),
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
              )
            ],
          );
        });
  }
}