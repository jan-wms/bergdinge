import 'package:flutter/material.dart';

import '../data/design.dart';

class CustomCheckBox extends StatelessWidget {
  final bool isChecked;
  final ValueChanged<bool> onChanged;
  final bool disabledColor;

  const CustomCheckBox({
    super.key,
    this.disabledColor = false,
    required this.isChecked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final fillColor = isChecked ? Design.green : Colors.white;
    final iconData = isChecked ? Icons.check : Icons.close;
    final borderColor = disabledColor
        ? Colors.black45
        : (!isChecked
            ? (Design.green.withValues(alpha: 0.6))
            : Colors.transparent);
    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(1.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: fillColor,
          border: Border.all(
            color: borderColor,
            width: 2.0,
          ),
        ),
        child: Icon(
          iconData,
          color: Colors.white,
          size: 18,
        ),
      ),
      onPressed: () => onChanged(!isChecked),
      mouseCursor: SystemMouseCursors.click,
    );
  }
}
