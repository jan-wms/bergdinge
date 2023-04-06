import 'package:equipment_app/data_models/packing_plan.dart';
import 'package:flutter/material.dart';

class PackingPlanDetails extends StatelessWidget {
  final PackingPlan packingPlan;
  const PackingPlanDetails({Key? key, required this.packingPlan}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(packingPlan.name),
        for (var sport in packingPlan.sports) Text(sport),
        for (var item in packingPlan.items) Text(item.equipment.name),
      ],
    );
  }
}
