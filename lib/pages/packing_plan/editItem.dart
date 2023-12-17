import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers.dart';
import '../../data_models/packing_plan.dart';
import '../../data_models/packing_plan_item.dart';
import '../../firebase/firebase_auth.dart';

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
  final count = StateProvider<int>((ref) => 1);
  late final StateProvider<int> location;

  @override
  void initState() {
    super.initState();
    location = StateProvider<int>((ref) => widget.location ?? 1);
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(packingPlanItemStreamProvider(widget.packingPlan.id)).when(
        error: (error, stackTrace) => Text(error.toString()),
        loading: () => const CircularProgressIndicator.adaptive(),
        data: (items) {

         PackingPlanItem? packingPlanItem = items.singleWhereOrNull(
                    (element) =>
                element.equipmentId == widget.equipmentId &&
                    element.location == ref.watch(location));


         ref.read(count.notifier).state = packingPlanItem?.equipmentCount ?? 1;

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
              ElevatedButton(
                  onPressed: () {
                    PackingPlanItem p = PackingPlanItem(
                        equipmentCount: ref.read(count),
                        equipmentId: widget.equipmentId,
                        isChecked: packingPlanItem?.isChecked ?? false,
                        location: ref.read(location));

                    DocumentReference docRef = FirebaseFirestore.instance
                        .collection('users')
                        .doc(Auth().user?.uid)
                        .collection('packing_plan')
                        .doc(widget.packingPlan.id)
                        .collection('items')
                        .doc('${widget.equipmentId}${ref.read(location)}');

                    if (packingPlanItem != null) {
                      docRef.delete().then((value) => context.pop());
                    } else {
                      docRef.set(p.toMap()).then((value) => context.pop());
                    }
                  },
                  child: (packingPlanItem != null)
                      ? const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Löschen'),
                            Icon(Icons.delete_rounded)
                          ],
                        )
                      : const Text('add to plan')),
              TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Abbrechen')),
            ],
          );
        });
  }
}
