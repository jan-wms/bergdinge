import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
  late final StateProvider<int> location;
  late final StateProviderFamily<PackingPlanItem?, List<PackingPlanItem>> itemProviderFamily;

  final countProviderFamily = StateProvider.family<int, PackingPlanItem?>((ref, p) => p?.equipmentCount ?? 1);

  @override
  void initState() {
    super.initState();
    location = StateProvider<int>((ref) => widget.location ?? 1);

    itemProviderFamily = StateProvider.family<PackingPlanItem?, List<PackingPlanItem>>((ref, items) {
      return items.singleWhereOrNull(
              (element) =>
          element.equipmentId == widget.equipmentId &&
              element.location == ref.watch(location));
    });
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(packingPlanItemStreamProvider(widget.packingPlan.id)).when(
        error: (error, stackTrace) => Text(error.toString()),
        loading: () => const CircularProgressIndicator.adaptive(),
        data: (items) {

          StateProvider<PackingPlanItem?> packingPlanProvider = itemProviderFamily(items);
          PackingPlanItem? packingPlanItem = ref.watch(packingPlanProvider);
          StateProvider<int> count = countProviderFamily(ref.watch(packingPlanProvider));

          DocumentReference docRef = FirebaseFirestore.instance
              .collection('users')
              .doc(Auth().user?.uid)
              .collection('packing_plan')
              .doc(widget.packingPlan.id)
              .collection('items')
              .doc('${widget.equipmentId}${ref.watch(location)}');


          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.location == null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('location:'),
                    DropdownButton(
                        items: [
                          for (var loc in widget.packingPlan.locations)
                            DropdownMenuItem(
                              value:
                                  widget.packingPlan.locations.indexOf(loc) + 1,
                              child: Text(loc),
                            )
                        ],
                        value: ref.watch(location),
                        onChanged: (newValue) =>
                            ref.read(location.notifier).state = newValue ?? 1),
                  ],
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
                      onPressed: () =>
                          ref.read(count.notifier).state = ref.read(count) + 1,
                      child: const Icon(Icons.chevron_right)),
                ],
              ),
              if (packingPlanItem != null) ElevatedButton(onPressed: () => docRef.delete().then((value) => context.pop()), child: const Row(mainAxisSize: MainAxisSize.min, children: [Text('Löschen'), Icon(Icons.delete_rounded)],)),
              if (packingPlanItem == null) ElevatedButton(onPressed: () {
                PackingPlanItem p = PackingPlanItem(
                    equipmentCount: ref.read(count),
                    equipmentId: widget.equipmentId,
                    isChecked: packingPlanItem?.isChecked ?? false,
                    location: ref.read(location));
                
                docRef.set(p.toMap()).then((value) => context.pop());
              }, child: const Row(mainAxisSize: MainAxisSize.min, children: [Text('add to plan'), Icon(Icons.add)],)),
              if (packingPlanItem != null) ElevatedButton(onPressed: () => docRef.update(
                  {'equipmentCount': ref.read(count)}).then((value) => context.pop()), child: const Row(mainAxisSize: MainAxisSize.min, children: [Text('update'), Icon(Icons.check)],)),
              
              TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Abbrechen')),
            ],
          );
        });
  }
}
