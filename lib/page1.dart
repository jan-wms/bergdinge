
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Page1 extends StatefulWidget {
  const Page1({super.key});

  @override
  State<Page1> createState() => _Page1State();
}

class _Page1State extends State<Page1> {

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'page 1',
            ),
            ElevatedButton(onPressed: () {
                  GoRouter.of(context).go('/page2');
            }, child: const Text('go to page 2'))
          ],
        ),
      );
  }
}
