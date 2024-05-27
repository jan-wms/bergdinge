import 'package:equipment_app/data/providers.dart';
import 'package:equipment_app/data_models/equipment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/design.dart';

class EquipmentCard extends ConsumerWidget {
  final Equipment equipment;
  final ValueSetter<String> onClick;
  final String? packingPlanId;

  const EquipmentCard(
      {super.key,
      required this.onClick,
      required this.equipment,
      this.packingPlanId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onClick(equipment.id),
        child: Hero(
          tag: 'image${equipment.id}',
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 150.0,
              height: 150.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: Design.colors[0],
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 4,
                    blurRadius: 10,
                    offset: const Offset(2, 3),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: getImagefromCategory(category: equipment.category),
                        )),
                        Text(
                          '${equipment.brand!} ${equipment.name}',
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  if (packingPlanId != null)
                    ref
                        .watch(packingPlanItemStreamProvider(packingPlanId!))
                        .when(
                          data: (data) {
                            if (data.indexWhere((element) =>
                                    element.equipmentId == equipment.id) !=
                                -1) {
                              return Container(
                                  decoration: BoxDecoration(
                                    //color: Colors.black.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  width: double.infinity,
                                  height: double.infinity,
                                  alignment: Alignment.center,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        right: 5.0,
                                        top: 5.0,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Container(
                                              decoration: const ShapeDecoration(
                                                shape: CircleBorder(),
                                                color: Colors.white,
                                              ),
                                              height: 25.0,
                                              width: 25.0,
                                            ),
                                            const Icon(
                                              Icons.check_circle_rounded,
                                              color: Colors.green,
                                              size: 35.0,
                                              weight: 400,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ));
                            }
                            return Positioned(
                              right: 5.0,
                              top: 5.0,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    decoration: const ShapeDecoration(
                                      shape: CircleBorder(),
                                      color: Colors.white,
                                    ),
                                    height: 25.0,
                                    width: 25.0,
                                  ),
                                  const Icon(
                                    Icons.add_circle_rounded,
                                    color: Colors.orange,
                                    size: 35.0,
                                    weight: 400,
                                  ),
                                ],
                              ),
                            );
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
