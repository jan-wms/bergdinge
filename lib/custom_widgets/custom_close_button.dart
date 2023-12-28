import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomCloseButton extends StatelessWidget {
  final dynamic returnValue;
  const CustomCloseButton({Key? key, this.returnValue}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () {
        if(context.canPop()) {
          context.pop(returnValue);
        }
      },
      style: FilledButton.styleFrom(
        backgroundColor: Colors.black54,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
      ),
      child: const Icon(Icons.close_rounded),
    );
  }
}
