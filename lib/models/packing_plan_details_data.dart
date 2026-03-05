import 'package:bergdinge/models/packing_plan.dart';
import 'package:bergdinge/models/packing_plan_item.dart';

import 'equipment.dart';

class PackingPlanDetailsData {
  final PackingPlan packingPlan;
  final List<Equipment> equipment;
  final List<PackingPlanItem> items;

  const PackingPlanDetailsData(
      {required this.packingPlan,
        required this.equipment,
        required this.items});
}