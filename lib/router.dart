import 'package:equipment_app/data_models/equipment.dart';
import 'package:equipment_app/data_models/packing_plan.dart';
import 'package:equipment_app/pages/authentication/verify_email_page.dart';
import 'package:equipment_app/pages/equipment/equipment_edit.dart';
import 'package:equipment_app/pages/equipment/equipment_details.dart';
import 'package:equipment_app/pages/home_page.dart';
import 'package:equipment_app/pages/authentication/login_page.dart';
import 'package:equipment_app/pages/equipment/equipment_page.dart';
import 'package:equipment_app/pages/introduction/introduction_page.dart';
import 'package:equipment_app/pages/introduction/setup_screen.dart';
import 'package:equipment_app/pages/packing_plan/packing_plan_details.dart';
import 'package:equipment_app/pages/packing_plan/packing_plan_edit.dart';
import 'package:equipment_app/pages/packing_plan/packing_plan_page.dart';
import 'package:equipment_app/pages/settings/settings_page.dart';
import 'package:equipment_app/split_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'firebase/firebase_auth.dart';

final _navigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _navigatorKey,
    initialLocation: '/setup',
    routes: [
      GoRoute(
        path: '/launch_screen',
        builder: (context, state) => const Scaffold(body: Placeholder()),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const IntroductionPage(),
      ),
      GoRoute(
        path: '/setup',
        builder: (context, state) => const SetupScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(isLinkingAccounts: false),
      ),
      GoRoute(
        path: '/link_accounts',
        builder: (context, state) => const LoginPage(isLinkingAccounts: true),
      ),
      GoRoute(
        path: '/verify_email',
        builder: (context, state) => const VerifyEmailPage(),
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
              path: '/settings',
              builder: (context, state) => const SettingsPage(),
            ),
            GoRoute(
                path: '/packing_plan',
                builder: (context, state) => const PackingPlanPage(),
                routes: [
                  GoRoute(
                      path: 'edit',
                      builder: (context, state) {
                        PackingPlan? p = state.extra as PackingPlan?;
                        return PackingPlanEdit(packingPlan: p);
                      }),
                  GoRoute(
                      path: 'details',
                      builder: (context, state) {
                        PackingPlan p = state.extra as PackingPlan;
                        return PackingPlanDetails(packingPlan: p);
                      }),
                ]),
            GoRoute(
                path: '/equipment',
                builder: (context, state) => const EquipmentPage(),
                routes: [
                  GoRoute(
                      path: 'edit',
                      builder: (context, state) {
                        Equipment? e = state.extra as Equipment?;
                        return EquipmentEdit(equipment: e);
                      }),
                  GoRoute(
                      path: 'details',
                      builder: (context, state) {
                        Equipment e = state.extra as Equipment;
                        return EquipmentDetails(equipment: e);
                      }),
                ]),
          ]),
    ],
    redirect: (context, state) {
      /*if (authState.isLoading || authState.hasError) return null;

      final isAuthorized = authState.valueOrNull != null;
      final isLoggingIn = state.location == '/login';
      if (isLoggingIn) return isAuthorized ? '/' : null;

      return isAuthorized ? null : '/login';*/

      if (authState.isLoading || authState.hasError) return '/launch_screen';
      final isAuthorized = authState.valueOrNull != null;
      final isLoggingIn = state.location == '/welcome';
      if (isLoggingIn) return isAuthorized ? '/' : null;

      return isAuthorized ? null : '/welcome';
    },
  );
});
