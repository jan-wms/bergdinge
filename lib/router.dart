import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bergdinge/data_models/article.dart';
import 'package:bergdinge/pages/equipment/equipment_details.dart';
import 'package:bergdinge/pages/error/error_page.dart';
import 'package:bergdinge/pages/home/article_page.dart';
import 'package:bergdinge/pages/home/home_page.dart';
import 'package:bergdinge/pages/equipment/equipment_page.dart';
import 'package:bergdinge/pages/introduction/introduction_page.dart';
import 'package:bergdinge/pages/setup/setup_screen.dart';
import 'package:bergdinge/pages/packing_plan/details/packing_plan_details.dart';
import 'package:bergdinge/pages/packing_plan/packing_plan_page.dart';
import 'package:bergdinge/pages/settings/settings_page.dart';
import 'package:bergdinge/split_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'firebase/firebase_auth.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/launch_screen',
        builder: (context, state) => const Scaffold(
          body: Placeholder(),
          backgroundColor: Colors.red,
        ),
      ),
      GoRoute(
        path: '/welcome',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const IntroductionPage(),
            transitionDuration: Duration.zero,
            transitionsBuilder: (_, __, ___, Widget child) => child,
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/setup',
        builder: (context, state) => SetupScreen(editValue: EditValue.setUp),
      ),
      ShellRoute(
          navigatorKey: _shellNavigatorKey,
          pageBuilder:
              (BuildContext context, GoRouterState state, Widget child) {
            return CustomTransitionPage(
              key: state.pageKey,
              child: SplitView(child: child),
              transitionDuration: Duration.zero,
              transitionsBuilder: (_, __, ___, Widget child) => child,
            );
          },
          routes: [
            GoRoute(
              path: '/',
              routes: [
                GoRoute(
                  path: 'article',
                  parentNavigatorKey: _rootNavigatorKey,
                  pageBuilder: (context, state) {
                    Article article = state.extra as Article;
                    return CustomTransitionPage(
                      fullscreenDialog: true,
                      opaque: false,
                      barrierDismissible: true,
                      key: state.pageKey,
                      child: ArticlePage(article: article),
                      transitionDuration: const Duration(milliseconds: 300),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) =>
                              FadeTransition(opacity: animation, child: child),
                    );
                  },
                ),
              ],
              pageBuilder: (context, state) {
                return CustomTransitionPage(
                  key: state.pageKey,
                  child: const HomePage(),
                  transitionDuration: Duration.zero,
                  transitionsBuilder: (_, __, ___, Widget child) => child,
                );
              },
            ),
            GoRoute(
              path: '/settings',
              pageBuilder: (context, state) {
                return CustomTransitionPage(
                  key: state.pageKey,
                  child: const SettingsPage(),
                  transitionDuration: Duration.zero,
                  transitionsBuilder: (_, __, ___, Widget child) => child,
                );
              },
            ),
            GoRoute(
                path: '/packing_plan',
                pageBuilder: (context, state) {
                  return CustomTransitionPage(
                    key: state.pageKey,
                    child: const PackingPlanPage(),
                    transitionDuration: Duration.zero,
                    transitionsBuilder: (_, __, ___, Widget child) => child,
                  );
                },
                routes: [
                  GoRoute(
                      //TODO
                      //parentNavigatorKey: _shellNavigatorKey,
                      parentNavigatorKey: _rootNavigatorKey,
                      path: 'details/:packingPlanId',
                      name: 'packingplanDetails',
                      builder: (context, state) {
                        String packingPlanId = state.pathParameters['packingPlanId']!;
                        return PackingPlanDetails(packingPlanId: packingPlanId);
                      }),
                ]),
            GoRoute(
                path: '/equipment',
                pageBuilder: (context, state) {
                  return CustomTransitionPage(
                    key: state.pageKey,
                    child: const EquipmentPage(),
                    transitionDuration: Duration.zero,
                    transitionsBuilder: (_, __, ___, Widget child) => child,
                  );
                },
                routes: [
                  GoRoute(
                    name: 'equipmentDetails',
                    path: 'details/:equipmentId/:transitionDelay',
                    parentNavigatorKey: _rootNavigatorKey,
                    pageBuilder: (context, state) {
                      String equipmentId = state.pathParameters['equipmentId']!;
                      int transitionDelay = int.parse(state.pathParameters['transitionDelay']!);
                      return CustomTransitionPage(
                        fullscreenDialog: true,
                        opaque: false,
                        barrierDismissible: true,
                        key: state.pageKey,
                        child: EquipmentDetails(equipmentID: equipmentId, transitionDelay: transitionDelay),
                        transitionDuration: Duration(milliseconds: transitionDelay),
                        transitionsBuilder: (context, animation,
                                secondaryAnimation, child) =>
                            FadeTransition(opacity: animation, child: child),
                      );
                    },
                  ),
                ]),
          ]),
    ],
    errorBuilder: (context, state) {
      return const ErrorPage();
    },
    redirect: (context, state) async {
      if (authState.isLoading || authState.hasError) return '/launch_screen';

      final isAuthorized = authState.valueOrNull != null;
      late final bool? isSetupCompleted;
      if (isAuthorized) {
        isSetupCompleted = await FirebaseFirestore.instance
            .collection("users")
            .doc(authState.value!.uid)
            .get()
            .then((DocumentSnapshot doc) {
          try {
            final data = doc.data() as Map<String, dynamic>;
            return data['isSetupCompleted'];
          } catch (e) {
            return false;
          }
        });
      }
      final isWelcome = state.uri.toString() == '/welcome';

      if (isWelcome) {
        return isAuthorized
            ? ((isSetupCompleted ?? false) ? '/' : '/setup')
            : null;
      }

      if (isAuthorized) {
        if (isSetupCompleted ?? false) {
          return null;
        } else {
          return '/setup';
        }
      } else {
        return '/welcome';
      }
    },
  );
});
