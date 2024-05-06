import 'package:flutter/material.dart';

import '../data/design.dart';

class CustomCheckBox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool disabled;

  const CustomCheckBox({
    super.key,
    this.disabled = false,
    required this.value,
    required this.onChanged,
  });

  @override
  State<CustomCheckBox> createState() => _CustomCheckBoxState();
}

class _CustomCheckBoxState extends State<CustomCheckBox> {
  late bool _checked;
  late CheckStatus _status;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didUpdateWidget(CustomCheckBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    _init();
  }

  void _init() {
    _checked = widget.value;
    if (_checked) {
      _status = CheckStatus.checked;
    } else {
      _status = CheckStatus.unchecked;
    }
  }

  Widget _buildIcon() {
    late Color fillColor;
    late IconData iconData;

    switch (_status) {
      case CheckStatus.checked:
        fillColor = Design.colors[1];
        iconData = Icons.check;
        break;
      case CheckStatus.unchecked:
        fillColor = Colors.white;
        iconData = Icons.close;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(1.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:  fillColor,
        border: Border.all(
          color: widget.disabled ? Colors.black45 : (!widget.value ? (Design.colors[1].withOpacity(0.6)) : Colors.transparent),
          width: 2.0,
        ),
      ),
      child: Icon(
        iconData,
        color: Colors.white,
        size: 18,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: _buildIcon(),
      onPressed: widget.disabled ? null : () => widget.onChanged(!_checked),
      mouseCursor: SystemMouseCursors.click,
    );
  }
}

enum CheckStatus {
  checked,
  unchecked,
}