import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data_models/packing_plan.dart';

class PackingPlanCard extends StatelessWidget {
  final PackingPlan packingPlan;

  const PackingPlanCard({Key? key, required this.packingPlan})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.push('/packing_plan/details', extra: packingPlan.id);
      },
      child: Card(
        child: Column(children: [
          Text(packingPlan.name),
          Text(packingPlan.sports.toString()),
        ]),
      ),
    );
  }
}
