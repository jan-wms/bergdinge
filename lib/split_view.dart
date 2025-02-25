import 'dart:math';

import 'package:bergdinge/data/design.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'menu.dart';

final tabIndexProvider = StateProvider.autoDispose<int>((ref) => 0);

class SplitView extends ConsumerStatefulWidget {
  const SplitView({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<SplitView> createState() => _SplitViewState();
}

class _SplitViewState extends ConsumerState<SplitView> {
  final List<IconData> icons = [
    Icons.explore_rounded,
    Icons.checklist_rounded,
    Icons.backpack_rounded,
    Icons.person_rounded,
  ];

  void goToTab({required int index}) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/');
        break;
      case 1:
        GoRouter.of(context).go('/packing_plan');
        break;
      case 2:
        GoRouter.of(context).go('/equipment');
        break;
      case 3:
        GoRouter.of(context).go('/settings');
        break;
      default:
        GoRouter.of(context).go('/');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final safeareaPadding = MediaQuery.of(context).padding;


    if (screenWidth > Design.breakpoint1 && MediaQuery.of(context).orientation == Orientation.landscape) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.black, // Android
            statusBarBrightness: Brightness.light // iOS
            ),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Row(
            children: [
              SafeArea(
                right: false,
                  top: false,
                  bottom: false,
                  child: Menu(onIndexChanged: (newIndex) => goToTab(index: newIndex), icons: icons)),
              Expanded(child: Padding(
                    padding: EdgeInsets.only(right: max(10.0, safeareaPadding.right), top: max(10.0, safeareaPadding.top)),
                      child: widget.child)),
            ],
          ),
        ),
      );
    } else {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.white, // Android
            statusBarBrightness: Brightness.dark // iOS.
            ),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            top: false,
            child: widget.child,),
          bottomNavigationBar: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                  icon: Icon(icons[0]), label: 'Entdecken'),
              BottomNavigationBarItem(
                  icon: Icon(icons[1]), label: 'Packlisten'),
              BottomNavigationBarItem(
                  icon: Icon(icons[2]), label: 'Ausrüstung'),
              BottomNavigationBarItem(
                  icon: Icon(icons[3]), label: 'Einstellungen'),
            ],
            currentIndex: ref.watch(tabIndexProvider),
            onTap: (int index) {
              ref.read(tabIndexProvider.notifier).state = index;
              goToTab(index: index);
            },
          ),
        ),
      );
    }
  }
}
