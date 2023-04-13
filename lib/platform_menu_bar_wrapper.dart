import 'dart:io';

import 'package:equipment_app/router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MenuSelection {
  about,
  preferences,
}

class PlatformMenuBarWrapper extends ConsumerWidget {
  final Widget child;
  const PlatformMenuBarWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    void handleMenuSelection(MenuSelection value) {
      switch (value) {
        case MenuSelection.about:
          router.go('/settings');
          break;
        case MenuSelection.preferences:
          router.go('/settings');
          break;
      }
    }
    if(kIsWeb || !Platform.isMacOS) {
      return child;
    }

    return PlatformMenuBar(
      menus: <PlatformMenuItem>[
        PlatformMenu(
          label: 'Equipment App',
          menus: <PlatformMenuItem>[
            PlatformMenuItemGroup(
              members: <PlatformMenuItem>[
                PlatformMenuItem(
                  label: 'About',
                  onSelected: () {
                    handleMenuSelection(MenuSelection.about);
                  },
                ),
              ],
            ),
            PlatformMenuItemGroup(
              members: <PlatformMenuItem>[
                PlatformMenuItem(
                  label: 'Einstellungen',
                  shortcut: const SingleActivator(LogicalKeyboardKey.comma,
                  meta: true),
                  onSelected: () => handleMenuSelection(MenuSelection.preferences),
                ),
              ],
            ),
            PlatformMenuItemGroup(members: <PlatformMenuItem>[
              if (PlatformProvidedMenuItem.hasMenu(
                  PlatformProvidedMenuItemType.hide ))
                const PlatformProvidedMenuItem(
                    type: PlatformProvidedMenuItemType.hide),
              if (PlatformProvidedMenuItem.hasMenu(
                  PlatformProvidedMenuItemType.hideOtherApplications))
                const PlatformProvidedMenuItem(
                    type: PlatformProvidedMenuItemType.hideOtherApplications),
              if (PlatformProvidedMenuItem.hasMenu(
                  PlatformProvidedMenuItemType.showAllApplications))
                const PlatformProvidedMenuItem(
                    type: PlatformProvidedMenuItemType.showAllApplications),
            ]),
            if (PlatformProvidedMenuItem.hasMenu(
                PlatformProvidedMenuItemType.servicesSubmenu))
              const PlatformProvidedMenuItem(
                  type: PlatformProvidedMenuItemType.quit),
          ],
        ),
        PlatformMenu(
          label: 'Flutter API Sample',
          menus: <PlatformMenuItem>[
            PlatformMenuItemGroup(
              members: <PlatformMenuItem>[
                PlatformMenuItem(
                  label: 'About',
                  onSelected: () {
                    handleMenuSelection(MenuSelection.about);
                  },
                ),
              ],
            ),
          ],
        ),
      ],
      child: child,
    );
  }
}
