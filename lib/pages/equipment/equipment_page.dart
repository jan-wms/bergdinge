import 'package:dismissible_page/dismissible_page.dart';
import 'package:equipment_app/custom_widgets/custom_appbar.dart';
import 'package:equipment_app/data/design.dart';
import 'package:equipment_app/pages/equipment/equipment_list.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'equipment_details.dart';

class EquipmentPage extends StatelessWidget {
  const EquipmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: CustomScrollView(
        slivers: <Widget>[
          CustomAppBar(
            title: 'Ausrüstung',
            onAddButtonPressed: () => context.push('/equipment/edit'),
          ),
          EquipmentList(
            onItemClick: (equipmentId) =>
                //TODO
                //context.pushTransparentRoute(EquipmentDetails(equipmentID: equipmentId)),
                context.push('/equipment/details', extra: equipmentId),
          ),
        ],
      ),
    );
  }
}
