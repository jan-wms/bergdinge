import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/design.dart';

class SidebarNavigation extends ConsumerWidget {
  final ValueSetter<int> onIndexChanged;
  final List<IconData> icons;

  const SidebarNavigation({super.key, required this.onIndexChanged, required this.icons});

  int _getIndex(String location) {
    if (location.startsWith('/settings')) {
      return 3;
    } else if (location.startsWith('/equipment')) {
      return 2;
    } else if (location.startsWith('/packing_plan')) {
      return 1;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = _getIndex(GoRouter.of(context).state.matchedLocation);

    return SafeArea(
      minimum: EdgeInsets.only(
        right: 10.0,
        top: 10.0,
        left: 10.0,
        bottom: 10.0,
      ),
      child: Container(
        width: 100.0,
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                spreadRadius: 5,
                color: Design.green.withValues(alpha: 0.2),
              )
            ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int index = 0; index < icons.length; index++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: InkWell(
                  onTap: () {
                    onIndexChanged(index);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                      color: (selectedIndex == index)
                          ? Design.green
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Icon(
                      icons[index],
                      color: (selectedIndex == index)
                          ? Colors.white
                          : Colors.grey,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
