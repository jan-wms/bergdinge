import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data_models/packing_plan.dart';

class PackingPlanCard extends StatelessWidget {
  final PackingPlan packingPlan;

  const PackingPlanCard({Key? key, required this.packingPlan})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        context.push('/packing_plan/details', extra: packingPlan.id);
      },
      title: Text(packingPlan.name, style: const TextStyle(fontWeight: FontWeight.w500),),
      subtitle: Text(packingPlan.sports.join(', ')),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}
