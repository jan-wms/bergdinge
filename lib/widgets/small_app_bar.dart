import 'dart:io';
import 'package:bergdinge/data/design.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SmallAppBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;

  const SmallAppBar({
    super.key,
    required this.title,
    this.actions,
  });

  bool get isIOS {
    if (kIsWeb) {
      return false;
    }
    if (Platform.isIOS || Platform.isMacOS) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final height = 80.0;

    final topInset = MediaQuery.of(context).padding.top;

    final isWide =
        (MediaQuery.of(context).size.width > Design.wideScreenBreakpoint &&
            MediaQuery.of(context).orientation == Orientation.landscape);

    return SafeArea(
      minimum: isWide
          ? const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0)
          : EdgeInsets.zero,
      top: isWide,
      bottom: false,
      child: Container(
        color: Colors.white,
        width: double.infinity,
        child: Column(
          children: [
            Container(
              height: topInset,
              color: Design.green,
            ),
            Container(
              width: double.infinity,
              height: height,
              decoration: BoxDecoration(
                color: Design.green,
                borderRadius: BorderRadius.vertical(
                  bottom: const Radius.circular(20.0),
                  top: isWide ? const Radius.circular(20) : Radius.zero,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 0.0,
                    child: IconButton(
                      color: Colors.white,
                      onPressed: () => context.pop(),
                      icon: Icon(isIOS
                          ? Icons.arrow_back_ios_new_rounded
                          : Icons.arrow_back_rounded),
                    ),
                  ),
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width - 90,
                    ),
                    child: Text(title,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                  ),
                  Positioned(
                      right: 0.0,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: actions ?? [],
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
