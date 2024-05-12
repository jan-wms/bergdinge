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

  final countProviderFamily = StateProvider.family<int, PackingPlanItem?>(
      (ref, p) => p?.equipmentCount ?? 1);

  late final StateProvider<int> dropdownIndexProvider;

  @override
  void initState() {
    super.initState();
    dropdownIndexProvider = StateProvider<int>((ref) => widget.location ?? 1);

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
                StateProvider<int> count =
                    countProviderFamily(ref.watch(packingPlanProvider));

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
                  children: [
                    TooltipVisibility(
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
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            int currentCount = ref.read(count);
                            if (currentCount > 1) {
                              ref.read(count.notifier).state = currentCount - 1;
                            }
                          },
                          child: const Icon(Icons.chevron_left),
                        ),
                        Text('${ref.watch(count)}'),
                        ElevatedButton(
                            onPressed: () => ref.read(count.notifier).state =
                                ref.read(count) + 1,
                            child: const Icon(Icons.chevron_right)),
                      ],
                    ),
                    if (packingPlanItem != null)
                      TextButton(
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
                    if (packingPlanItem == null)
                      ElevatedButton(
                          onPressed: () {
                            PackingPlanItem p = PackingPlanItem(
                                equipmentCount: ref.read(count),
                                equipmentId: widget.equipmentId,
                                isChecked: packingPlanItem?.isChecked ?? false,
                                location: ref.read(dropdownIndexProvider));

                            docRef
                                .set(p.toMap())
                                .then((value) => context.pop());
                          },
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [Text('add to plan'), Icon(Icons.add)],
                          )),
                    if (packingPlanItem != null)
                      ElevatedButton(
                          onPressed: () => docRef
                              .update({'equipmentCount': ref.read(count)}).then(
                                  (value) => context.pop()),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [Text('Fertig'), Icon(Icons.check)],
                          )),
                  ],
                );
              }),
    );
  }
}
