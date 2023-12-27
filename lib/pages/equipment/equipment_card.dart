import 'package:equipment_app/data/providers.dart';
import 'package:equipment_app/data_models/equipment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EquipmentCard extends ConsumerWidget {
  final Equipment equipment;
  final ValueSetter<String> onClick;
  final String? packingPlanId;

  const EquipmentCard(
      {Key? key,
      required this.onClick,
      required this.equipment,
      this.packingPlanId})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => onClick(equipment.id),
          child: Hero(
            tag: 'image${equipment.id}',
            child: Container(
              width: 200.0,
              height: 200.0,
              color: Colors.greenAccent,
              padding: const EdgeInsets.only(bottom: 20.0, top: 40.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    children: [
                      Expanded(child: Image.asset('assets/items/map.png')),
                      Text('${equipment.brand!} ${equipment.name}'),
                    ],
                  ),
                  if (packingPlanId != null)
                    ref
                        .watch(packingPlanItemStreamProvider(packingPlanId!))
                        .when(
                          data: (data) {
                            if (data.indexWhere((element) =>
                                    element.equipmentId == equipment.id) !=
                                -1) {
                              return const Align(
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.check_circle_outline_outlined,
                                    size: 50.0,
                                  ));
                            }
                            return Container();
                          },
                          error: (Object error, StackTrace stackTrace) =>
                              Text(error.toString()),
                          loading: () => Container(),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
