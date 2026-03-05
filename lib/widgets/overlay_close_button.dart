import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OverlayCloseButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const OverlayCloseButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () {
        onPressed?.call();
        if(context.canPop()) {
          context.pop();
        }
      },
      style: FilledButton.styleFrom(
        padding: EdgeInsets.zero,
        backgroundColor: Colors.black54,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
      ),
      child: const Icon(Icons.close_rounded),
    );
  }
}