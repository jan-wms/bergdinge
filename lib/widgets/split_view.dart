import 'package:bergdinge/data/design.dart';
import 'package:bergdinge/widgets/sidebar_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SplitView extends ConsumerStatefulWidget {
  const SplitView({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SplitView> createState() => _SplitViewState();
}

class _SplitViewState extends ConsumerState<SplitView> {
  final Map<String, IconData> icons = {
    "Entdecken": Icons.explore_rounded,
    "Packlisten": Icons.checklist_rounded,
    'Ausrüstung': Icons.backpack_rounded,
    'Einstellungen': Icons.person_rounded,
  };

  void changeTab(int index) {
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
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final currentIndex = _getIndex(GoRouter.of(context).state.matchedLocation);

    if (screenWidth > Design.wideScreenBreakpoint &&
        MediaQuery.of(context).orientation == Orientation.landscape) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.black, // Android
            statusBarBrightness: Brightness.light // iOS
            ),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Row(
            children: [
              SidebarNavigation(
                  onIndexChanged: (index) => changeTab(index),
                  icons: icons.values.toList()),
              Expanded(
                child: SafeArea(
                  top: true,
                  right: true,
                  left: false,
                  bottom: false,
                  minimum: EdgeInsets.only(right: 10.0, top: 10.0),
                  child: widget.child,
                ),
              ),
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
            child: widget.child,
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: [
              for (final entry in icons.entries)
                BottomNavigationBarItem(
                    icon: Icon(entry.value), label: entry.key),
            ],
            currentIndex: currentIndex,
            onTap: (int index) {
              changeTab(index);
            },
          ),
        ),
      );
    }
  }
}
