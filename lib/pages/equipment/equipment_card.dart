import 'package:equipment_app/data_models/equipment.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EquipmentCard extends StatelessWidget {
  final Equipment equipment;

  const EquipmentCard({Key? key, required this.equipment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: InkWell(
        child: Card(
          child: Text('${equipment.brand!} ${equipment.name}'),
        ),
        onTap: () {
          context.push('/equipment/details', extra: equipment.id);
        },
      ),
    );
  }
}
