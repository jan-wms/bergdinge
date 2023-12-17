import 'package:equipment_app/data_models/equipment.dart';
import 'package:equipment_app/pages/equipment/equipment_list.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EquipmentCard extends StatelessWidget {
  final Equipment equipment;
  final ValueSetter<String> onClick;

  const EquipmentCard({Key? key, required this.onClick, required this.equipment}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: InkWell(
            child: Stack(
              children: [
                Card(
                  child: Text('${equipment.brand!} ${equipment.name}'),
                ),
                const Icon(Icons.check_circle_outline_outlined),
              ],
            ),
            onTap: () => onClick(equipment.id),
          ),
    );
  }
}
