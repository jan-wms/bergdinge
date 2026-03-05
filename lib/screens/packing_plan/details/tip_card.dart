import 'package:flutter/material.dart';

import '../../../data/design.dart';
import '../../../models/tip.dart';

class TipCard extends StatelessWidget {
  final Tip tip;
  final bool isConditionMet;

  const TipCard({super.key, required this.tip, required this.isConditionMet});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(5.0),
          margin: Design.pagePadding.copyWith(bottom: 10.0),
          decoration: BoxDecoration(
              color: Color.fromRGBO(146, 184, 135, 1.0),
              borderRadius: BorderRadius.circular(15.0)),
          child: Row(
            children: [
              Container(
                  margin: const EdgeInsets.all(15.0).copyWith(right: 25.0),
                  width: 70,
                  height: 70,
                  child: Image.asset('assets/${tip.imagePath}')),
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(
                    minHeight: 100.0,
                  ),
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tip.title,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        tip.subTitle,
                        style: const TextStyle(
                            fontSize: 15, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 10,
          right: 25,
          child: Container(
            padding: EdgeInsets.all(3.0),
            decoration: ShapeDecoration(
                shape: CircleBorder(),
                color: isConditionMet ? Colors.green : Colors.orange),
            child: Icon(
              isConditionMet ? Icons.check : Icons.error_rounded,
              color: Colors.white,
              size: 20.0,
            ),
          ),
        ),
      ],
    );
  }
}
