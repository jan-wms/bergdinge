import 'package:equipment_app/pages/equipment/equipment_list.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class EquipmentPage extends StatelessWidget {
  const EquipmentPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(),
              const Text(
                'Meine Ausrüstung',
              ),
              ElevatedButton(
                  onPressed: () => context.push('/equipment/edit'),
                  child: const Text('Gegenstand hinzufügen')),
            ],
          ),
          const Expanded(child: EquipmentList(action: EquipmentListAction.show)),
        ],
      ),
    );
  }
}
