import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equipment_app/data_models/equipment.dart';
import 'package:equipment_app/data_models/packing_plan.dart';
import 'package:equipment_app/pages/equipment/equipment_edit.dart';
import 'package:equipment_app/pages/equipment/equipment_details.dart';
import 'package:equipment_app/pages/home_page.dart';
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
        builder: (context, state) => const Scaffold(body: Placeholder()),
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
        name: 'setup',
        builder: (context, state) => SetupScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
          builder: (BuildContext context, GoRouterState state, Widget child) {
            return SplitView(child: child);
          },
          routes: [
            GoRoute(
              path: '/',
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
                      path: 'edit',
                      builder: (context, state) {
                        PackingPlan? p = state.extra as PackingPlan?;
                        return PackingPlanEdit(packingPlan: p);
                      }),
                  GoRoute(
                      path: 'details',
                      builder: (context, state) {
                        String packingPlanID = state.extra as String;
                        return PackingPlanDetails(packingPlanID: packingPlanID);
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
                      path: 'edit',
                      builder: (context, state) {
                        Equipment? e = state.extra as Equipment?;
                        return EquipmentEdit(equipment: e);
                      }),
                  GoRoute(
                      path: 'details',
                      builder: (context, state) {
                        String equipmentID = state.extra as String;
                        return EquipmentDetails(equipmentID: equipmentID);
                      }),
                ]),
          ]),
    ],
    redirect: (context, state) async {
      if (authState.isLoading || authState.hasError) return '/launch_screen';

      final isAuthorized = authState.valueOrNull != null;
      late final bool? isSetupCompleted;
      if (isAuthorized) {
        isSetupCompleted = await FirebaseFirestore.instance
            .collection("users").doc(authState.value!.uid).get().then(
                (DocumentSnapshot doc) {
              try {
                final data = doc.data() as Map<String, dynamic>;
                return data['isSetupCompleted'];
              } catch (e) {
                return false;
              }
            });
      }
      final isWelcome = state.location == '/welcome';

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
