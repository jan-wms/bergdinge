import 'dart:math';

import 'package:equipment_app/split_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/design.dart';

class Menu extends ConsumerWidget {
  final ValueSetter<int> onIndexChanged;
  final List<IconData> icons;

  const Menu({super.key, required this.onIndexChanged, required this.icons});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeareaPadding = MediaQuery.of(context).padding;

    return Container(
      width: 100.0,
      padding: const EdgeInsets.all(10.0),
      margin: EdgeInsets.only(
        right: 10.0,
        top: max(10.0, safeareaPadding.top),
        left: max(10.0, safeareaPadding.left),
        bottom: max(10.0, safeareaPadding.bottom),
      ),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              spreadRadius: 5,
              color: Design.colors[1].withOpacity(0.2),
            )
          ]),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int index = 0; index < icons.length; index++)
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      ref.read(tabIndexProvider.notifier).state = index;
                      onIndexChanged(index);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(15.0),
                      decoration: BoxDecoration(
                        color: (ref.watch(tabIndexProvider) == index)
                            ? Design.colors[1]
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Icon(
                        icons[index],
                        color: (ref.watch(tabIndexProvider) == index)
                            ? Colors.white
                            : Colors.grey,
                      ),
                    ),
                  ),
                )),
        ],
      ),
    );
  }
}
