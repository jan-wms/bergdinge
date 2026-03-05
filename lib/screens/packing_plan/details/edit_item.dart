import 'package:bergdinge/models/packing_plan_location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../widgets/popupitem_extension.dart';
import '../../../data/design.dart';
import '../../../firebase/firebase_data_providers.dart';
import '../../../models/packing_plan_item.dart';
import '../../../firebase/firebase_auth.dart';

class EditItem extends ConsumerStatefulWidget {
  const EditItem(
      {super.key,
      required this.equipmentId,
      required this.packingPlanId,
      this.location});

  final String equipmentId;
  final String packingPlanId;
  final PackingPlanLocation? location;

  @override
  ConsumerState<EditItem> createState() => _EditItemState();
}

class _EditItemState extends ConsumerState<EditItem> {
  late PackingPlanLocation _selectedLocation;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.location ?? PackingPlanLocation.backpack;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ref.watch(packingPlanDetailsProvider(widget.packingPlanId)).when(
          error: (error, stackTrace) => Text(error.toString()),
          loading: () => const Center(child: CircularProgressIndicator()),
          data: (data) {


            final PackingPlanItem? item = data.items.singleWhereOrNull((element) =>
                element.equipmentId == widget.equipmentId &&
                element.location == _selectedLocation);

            DocumentReference docRef = FirebaseFirestore.instance
                .collection('users')
                .doc(Auth().user?.uid)
                .collection('packing_plan')
                .doc(widget.packingPlanId)
                .collection('items')
                .doc(
                    '${widget.equipmentId}-${_selectedLocation.name}');

            bool isDrink = data.equipment
                    .singleWhere((element) => element.id == widget.equipmentId)
                    .category ==
                '3.0';

            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  constraints: const BoxConstraints(
                    maxWidth: 150,
                  ),
                  child: TooltipVisibility(
                    visible: false,
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        splashFactory: NoSplash.splashFactory,
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                      ),
                      child: PopupMenuButton(
                        color: Colors.white,
                        splashRadius: 100,
                        surfaceTintColor: Colors.white,
                        itemBuilder: (context) => [
                          for (PackingPlanLocation location
                              in PackingPlanLocation.values)
                            CustomPopupMenuItem(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 5.0, right: 5.0, top: 10.0),
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                      foregroundColor: Design.darkGreen,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0))),
                                  onPressed: () {
                                    context.pop();
                                    setState(() {
                                      _selectedLocation = location;
                                    });
                                  },
                                  child: Text(
                                    location.label,
                                    style: const TextStyle(fontSize: 17),
                                  ),
                                ),
                              ),
                            ),
                        ],
                        child: Container(
                          padding: const EdgeInsets.all(7.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            border: Border.all(color: Colors.black38),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedLocation.label,
                                style: TextStyle(
                                    fontSize: 17, color: Design.darkGreen),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Colors.black38,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (item != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                            style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0))),
                            onPressed: () {
                              if (item.equipmentCount >
                                  (isDrink ? 50 : 1)) {
                                int newValue =
                                    item.equipmentCount - (isDrink ? 50 : 1);

                                docRef.update({'equipmentCount': (newValue)});
                              }
                            },
                            child: const Icon(Icons.chevron_left_rounded)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                            '${item.equipmentCount.toString()}${isDrink ? ' ml' : ''}',
                            style: const TextStyle(fontSize: 17),
                          ),
                        ),
                        TextButton(
                            style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0))),
                            onPressed: () {
                              int newValue =
                                  item.equipmentCount + (isDrink ? 50 : 1);

                              docRef.update({'equipmentCount': (newValue)});
                            },
                            child: const Icon(Icons.chevron_right_rounded)),
                      ],
                    ),
                  ),
                if (item != null)
                  Container(
                    margin: const EdgeInsets.only(top: 10.0),
                    constraints: const BoxConstraints(
                      maxWidth: 150.0,
                    ),
                    child: TextButton(
                      onPressed: () => docRef.delete().then((value) {
                        if (context.mounted) {
                          context.pop();
                        }
                      }),
                      style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0))),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete_rounded),
                          Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Text('Löschen'),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (item == null)
                  Container(
                    margin: const EdgeInsets.only(top: 20.0),
                    constraints: const BoxConstraints(
                      maxWidth: 150.0,
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        PackingPlanItem p = PackingPlanItem(
                            equipmentCount: (isDrink ? 1000 : 1),
                            equipmentId: widget.equipmentId,
                            isChecked: false,
                            location: _selectedLocation);

                        docRef.set(p.toMap()).then((_) {
                          if (context.mounted) {
                            context.pop();
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.only(
                              left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
                          foregroundColor: Colors.white,
                          backgroundColor: Design.green,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0))),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_rounded),
                          Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Text('Hinzufügen'),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          }),
    );
  }
}
