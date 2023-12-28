import 'package:flutter/material.dart';
import '../data/design.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  final VoidCallback? onAddButtonPressed;
  const CustomAppBar({super.key, required this.title, this.onAddButtonPressed});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      stretch: true,
      expandedHeight: 100,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: Design.pagePadding,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
      ),
      title: Text(title),
      pinned: true,
      actions: [
        if(onAddButtonPressed != null)
        FilledButton(
          onPressed: () => onAddButtonPressed!(),
          style: FilledButton.styleFrom(
            backgroundColor: Design.colors[1],
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
          ),
          child: const Icon(
            Icons.add_rounded,
          ),
        ),
      ],
    );
  }
}
