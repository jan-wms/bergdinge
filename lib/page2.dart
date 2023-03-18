
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Page2 extends StatefulWidget {
  const Page2({super.key});

  @override
  State<Page2> createState() => _Page2State();
}

class _Page2State extends State<Page2> {

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'page 2',
          ),
          ElevatedButton(onPressed: () {
            GoRouter.of(context).go('/');
          }, child: const Text('go to page 1'))
        ],
      ),
    );
  }
}