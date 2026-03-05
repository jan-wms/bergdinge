import 'package:bergdinge/data/design.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/packing_plan.dart';

class PackingPlanCard extends StatelessWidget {
  final PackingPlan packingPlan;

  const PackingPlanCard({super.key, required this.packingPlan});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        context.pushNamed('packingplanDetails', pathParameters: {'packingPlanId': packingPlan.id});
      },
      title: Text(
        packingPlan.name,
        style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Design.darkGreen,
            fontSize: 17.0),
      ),
      subtitle: Text(
        packingPlan.sports.join(', '), overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}
