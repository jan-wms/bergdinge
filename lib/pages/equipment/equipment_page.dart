import 'package:dismissible_page/dismissible_page.dart';
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
      child: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 100,
            flexibleSpace: const FlexibleSpaceBar(
              title: Text(
                "Ausrüstung",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              titlePadding: EdgeInsets.zero,
              centerTitle: false,
            ),
            title: const Text('Ausrüstung'),
            pinned: true,
            actions: [
              FilledButton(
                onPressed: () => context.push('/equipment/edit'),
                style: FilledButton.styleFrom(
                  backgroundColor: Design.colors[1],
                  foregroundColor: Colors.white,
                  shape: const CircleBorder(),
                ),
                child: const Icon(
                  Icons.add_rounded,
                ),
              ),
            ],
          ),
          const SliverToBoxAdapter(
              child: SizedBox(height: 900, child: Placeholder()))

          /*EquipmentList(onItemClick: (equipmentId) =>
                context.pushTransparentRoute(EquipmentDetails(equipmentID: equipmentId),),
              //context.push('/equipment/details', extra: equipmentId),
            ),
          ),*/
        ],
      ),
    );
  }
}
