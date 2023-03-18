import 'package:equipment_app/login_page.dart';
import 'package:equipment_app/page1.dart';
import 'package:equipment_app/page2.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:go_router/go_router.dart';

Future<void> main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

final _router = GoRouter(
  redirect: (context, state) {
    if(true) {
      return '/login';
    } else {
      return null;
    }
  },
  routes: [
    GoRoute(path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return Scaffold(
            body: child,
            appBar: AppBar(),
            drawer: Drawer(
              child: ListView(
                children: [
                  ListTile(
                    title: const Text('Entdecken'),
                    onTap: () => GoRouter.of(context).go('/'),
                  ),
                  ListTile(
                    title: const Text('Packlisten'),
                    onTap: () => GoRouter.of(context).go('/page2'),
                  ),
                  ListTile(
                    title: const Text('Ausrüstung'),
                    onTap: () => GoRouter.of(context).go('/page2'),
                  ),
                  ListTile(
                    title: const Text('Einstellungen'),
                    onTap: () => GoRouter.of(context).go('/page2'),
                  ),
                ],
              ),
            ),
          );
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Page1(),
          ),
          GoRoute(
            path: '/page2',
            builder: (context, state) => const Page2(),
          ),
        ]),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Equipment App',
      routerConfig: _router,
    );
  }
}
