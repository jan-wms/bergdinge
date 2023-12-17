import 'package:equipment_app/data/providers.dart';
import 'package:equipment_app/data_models/equipment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EquipmentCard extends ConsumerWidget {
  final Equipment equipment;
  final ValueSetter<String> onClick;
  final String? packingPlanId;

  const EquipmentCard({Key? key, required this.onClick, required this.equipment, this.packingPlanId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: 200,
      height: 200,
      child: InkWell(
            child: Stack(
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Card(
                    child: Text('${equipment.brand!} ${equipment.name}'),
                  ),
                ),
                if(packingPlanId != null)
                  ref.watch(packingPlanItemStreamProvider(packingPlanId!)).when(
                    data: (data) {
                      if(data.indexWhere((element) => element.equipmentId == equipment.id) != -1) {
                        return const Align(alignment: Alignment.center, child: Icon(Icons.check_circle_outline_outlined, size: 50.0,));
                      }
                      return Container();
                    }, error: (Object error, StackTrace stackTrace) => Text(error.toString()), loading: () => Container(),),
              ],
            ),
            onTap: () => onClick(equipment.id),
          ),
    );
  }
}
