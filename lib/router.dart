import 'package:equipment_app/pages/home_page.dart';
import 'package:equipment_app/pages/login_page.dart';
import 'package:equipment_app/pages/equipment_page.dart';
import 'package:equipment_app/split_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'firebase/firebase_auth.dart';
import 'menu.dart';

final _key = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _key,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      ShellRoute(
          builder: (BuildContext context, GoRouterState state, Widget child) {
            return SplitView(child: child);
          },
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const HomePage(),
            ),
            GoRoute(
              path: '/page2',
              builder: (context, state) => const EquipmentPage(),
            ),
          ]),
    ],
    redirect: (context, state) {
      if (authState.isLoading || authState.hasError) return null;

      final isAuthorized = authState.valueOrNull != null;
      final isLoggingIn = state.location == '/login';
      if (isLoggingIn) return isAuthorized ? '/' : null;

      return isAuthorized ? null : '/login';
    },
  );
});
