import 'package:flutter/material.dart';

import 'menu.dart';

class SplitView extends StatelessWidget {
  const SplitView({Key? key, required this.child}) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth > 600) {
      return Scaffold(
        body: Row(
          children: [
            const SizedBox(
              width: 250,
              child: Menu(),
            ),
            Expanded(child: child),
          ],
        ),
      );
    } else {
      return Scaffold(
        body: child,
        appBar: AppBar(),
        drawer: const Drawer(
          child: Menu(),
        ),
      );
    }
  }
}
