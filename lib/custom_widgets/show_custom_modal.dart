import 'package:flutter/material.dart';

Future<void> showCustomModal (BuildContext context, Widget child, Widget? left, Widget right) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          maxChildSize: 0.9,
          minChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    left ?? Container(),
                    right,
                  ],
                ),
                Expanded(
                  child: child,
                ),
              ],
            );
          },
        );
      },
    );
}