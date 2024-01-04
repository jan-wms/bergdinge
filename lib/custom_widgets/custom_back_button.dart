import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomBackButton extends StatelessWidget {
  final dynamic returnValue;
  const CustomBackButton({Key? key, this.returnValue}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.chevron_left_rounded, size: 40.0,),
      onPressed: () {
        if(context.canPop()) {
          context.pop(returnValue);
        }
      },
    );
  }
}
