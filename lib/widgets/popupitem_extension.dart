import 'package:flutter/material.dart';

class CustomPopupMenuItem extends PopupMenuItem {
  const CustomPopupMenuItem({
    required Widget super.child,
    super.key,
  });

  @override
  PopupMenuItemState createState() => _CustomPopupMenuItem();
}

class _CustomPopupMenuItem extends PopupMenuItemState {
  @override
  void handleTap() {}

  @override
  Widget build(BuildContext context) {
    return widget.child ?? Container();
  }
}