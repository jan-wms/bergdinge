import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../custom_widgets/popupitem_extension.dart';
import '../../../data/design.dart';
import '../../../data/providers.dart';
import '../../../data_models/packing_plan.dart';
import '../../../data_models/packing_plan_item.dart';
import '../../../firebase/firebase_auth.dart';

class EditItem extends ConsumerStatefulWidget {
  const EditItem(
      {super.key,
      required this.equipmentId,
      required this.packingPlan,
      this.location});

  final String equipmentId;
  final PackingPlan packingPlan;
  final int? location;

  @override
  ConsumerState<EditItem> createState() => _EditItemState();
}

class _EditItemState extends ConsumerState<EditItem> {
  late final StateProviderFamily<PackingPlanItem?, List<PackingPlanItem>>
      itemProviderFamily;

  late final StateProvider<int> dropdownIndexProvider;

  @override
  void initState() {
    super.initState();
    dropdownIndexProvider = StateProvider<int>((ref) => widget.location ?? 2);

    itemProviderFamily =
        StateProvider.family<PackingPlanItem?, List<PackingPlanItem>>(
            (ref, items) {
      return items.singleWhereOrNull((element) =>
          element.equipmentId == widget.equipmentId &&
          element.location == ref.watch(dropdownIndexProvider));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child:
          ref.watch(packingPlanItemStreamProvider(widget.packingPlan.id)).when(
              error: (error, stackTrace) => Text(error.toString()),
              loading: () => const CircularProgressIndicator.adaptive(),
              data: (items) {
                StateProvider<PackingPlanItem?> packingPlanProvider =
                    itemProviderFamily(items);
                PackingPlanItem? packingPlanItem =
                    ref.watch(packingPlanProvider);

                DocumentReference docRef = FirebaseFirestore.instance
                    .collection('users')
                    .doc(Auth().user?.uid)
                    .collection('packing_plan')
                    .doc(widget.packingPlan.id)
                    .collection('items')
                    .doc(
                        '${widget.equipmentId}${ref.watch(dropdownIndexProvider)}');

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
                              for (String location
                                  in widget.packingPlan.locations)
                                CustomPopupMenuItem(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5.0, right: 5.0, top: 10.0),
                                    child: TextButton(
                                      style: TextButton.styleFrom(
                                          foregroundColor: Design.colors[0],
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0))),
                                      onPressed: () {
                                        context.pop();
                                        ref
                                            .read(dropdownIndexProvider.notifier)
                                            .state = widget.packingPlan.locations
                                                .indexWhere((element) =>
                                                    element == location) +
                                            1;
                                      },
                                      child: Text(
                                        location,
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
                                    widget.packingPlan.locations[
                                        ref.watch(dropdownIndexProvider) - 1],
                                    style: TextStyle(
                                        fontSize: 17, color: Design.colors[0]),
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
                    if (packingPlanItem != null)
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
                                if ((ref
                                            .watch(packingPlanItemStreamProvider(
                                                widget.packingPlan.id))
                                            .value
                                            ?.singleWhere((element) =>
                                                element.equipmentId ==
                                                    widget.equipmentId &&
                                                element.location ==
                                                    ref.read(
                                                        dropdownIndexProvider))
                                            .equipmentCount ??
                                        0) >
                                    1) {
                                  int newValue = (ref
                                              .watch(
                                                  packingPlanItemStreamProvider(
                                                      widget.packingPlan.id))
                                              .value
                                              ?.singleWhere((element) =>
                                                  element.equipmentId ==
                                                      widget.equipmentId &&
                                                  element.location ==
                                                      ref.read(
                                                          dropdownIndexProvider))
                                              .equipmentCount ??
                                          0) -
                                      1;

                                  docRef.update({'equipmentCount': (newValue)});
                                }
                              },
                              child: const Icon(Icons.chevron_left_rounded)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text(
                              ref
                                      .watch(packingPlanItemStreamProvider(
                                          widget.packingPlan.id))
                                      .value
                                      ?.singleWhereOrNull((element) =>
                                          element.equipmentId ==
                                              widget.equipmentId &&
                                          element.location ==
                                              ref.read(dropdownIndexProvider))
                                      ?.equipmentCount
                                      .toString() ??
                                  '',
                              style: const TextStyle(fontSize: 17),
                            ),
                          ),
                          TextButton(
                              style: TextButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0))),
                              onPressed: () {
                                int newValue = (ref
                                            .watch(packingPlanItemStreamProvider(
                                                widget.packingPlan.id))
                                            .value
                                            ?.singleWhere((element) =>
                                                element.equipmentId ==
                                                    widget.equipmentId &&
                                                element.location ==
                                                    ref.read(
                                                        dropdownIndexProvider))
                                            .equipmentCount ??
                                        0) +
                                    1;

                                docRef.update({'equipmentCount': (newValue)});
                              },
                              child: const Icon(Icons.chevron_right_rounded)),
                        ],
                      ),
                    ),
                    if (packingPlanItem != null)
                      Container(
                        margin: const EdgeInsets.only(top: 10.0),
                        constraints: const BoxConstraints(
                          maxWidth: 150.0,
                        ),
                        child: TextButton(
                          onPressed: () =>
                              docRef.delete().then((value) => context.pop()),
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
                    if (packingPlanItem == null)
                      Container(
                        margin: const EdgeInsets.only(top: 20.0),
                        constraints: const BoxConstraints(
                          maxWidth: 150.0,
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            PackingPlanItem p = PackingPlanItem(
                                equipmentCount: 1,
                                equipmentId: widget.equipmentId,
                                isChecked: packingPlanItem?.isChecked ?? false,
                                location: ref.read(dropdownIndexProvider));

                            docRef
                                .set(p.toMap());
                          },
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.only(
                                  left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
                              foregroundColor: Colors.white,
                              backgroundColor: Design.colors[1],
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
