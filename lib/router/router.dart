import 'package:bergdinge/router/app_state_provider.dart';
import 'package:bergdinge/models/app_state.dart';
import 'package:bergdinge/models/article.dart';
import 'package:bergdinge/screens/equipment/equipment_details.dart';
import 'package:bergdinge/screens/error/error_page.dart';
import 'package:bergdinge/screens/home/article_page.dart';
import 'package:bergdinge/screens/home/home_page.dart';
import 'package:bergdinge/screens/equipment/equipment_page.dart';
import 'package:bergdinge/screens/welcome/welcome_screen.dart';
import 'package:bergdinge/screens/setup/loading_page.dart';
import 'package:bergdinge/screens/setup/setup_screen.dart';
import 'package:bergdinge/screens/packing_plan/packing_plan_page.dart';
import 'package:bergdinge/screens/settings/settings_page.dart';
import 'package:bergdinge/widgets/split_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../screens/packing_plan/details/details.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/loading',
          pageBuilder: (context, state) {
            return CustomTransitionPage(
              key: state.pageKey,
              child: Scaffold(
                  backgroundColor: Colors.white,
                  body: LoadingPage(onInit: () {}, editValue: EditValue.none)),
              transitionDuration: Duration.zero,
              transitionsBuilder: (_, __, ___, Widget child) => child,
            );
          },
        ),
        GoRoute(
          path: '/welcome',
          pageBuilder: (context, state) {
            return CustomTransitionPage(
              key: state.pageKey,
              child: const WelcomeScreen(),
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
                        transitionsBuilder: (context, animation,
                                secondaryAnimation, child) =>
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
                        parentNavigatorKey: _rootNavigatorKey,
                        path: 'details/:packingPlanId',
                        name: 'packingplanDetails',
                        builder: (context, state) {
                          String packingPlanId =
                              state.pathParameters['packingPlanId']!;
                          return Details(packingPlanId: packingPlanId);
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
                      path: 'details/:equipmentId',
                      parentNavigatorKey: _rootNavigatorKey,
                      pageBuilder: (context, state) {
                        final String equipmentId =
                            state.pathParameters['equipmentId']!;
                        final extra = state.extra as Map<String, dynamic>?;
                        final int transitionDelay =
                            extra?['transitionDelay'] ?? 0;
                        return CustomTransitionPage(
                          fullscreenDialog: true,
                          opaque: false,
                          barrierDismissible: true,
                          key: state.pageKey,
                          child: EquipmentDetails(
                              equipmentId: equipmentId,
                              transitionDelay: transitionDelay),
                          transitionDuration:
                              Duration(milliseconds: transitionDelay),
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
        return ErrorPage(exception: state.error);
      },
      redirect: (context, state) async {
        final appState = ref.read(appStateProvider).value;

        if (appState == null) return null;

        switch (appState) {
          case AppState.loading:
            return (state.matchedLocation == '/loading') ? null : '/loading';
          case AppState.unauthenticated:
            return (state.matchedLocation == '/welcome') ? null : '/welcome';
          case AppState.needsSetup:
            return (state.matchedLocation == '/setup') ? null : '/setup';
          case AppState.ready:
            return (state.matchedLocation == '/welcome' ||
                    state.matchedLocation == '/loading')
                ? '/'
                : null;
        }
      });

  ref.listen(appStateProvider, (_, __) {
    router.refresh();
  });

  return router;
});
