import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equipment_app/custom_widgets/custom_dialog.dart';
import 'package:equipment_app/data_models/equipment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data_models/category.dart';
import '../../firebase/firebase_auth.dart';
import '../../data/data.dart';
import 'package:equipment_app/data/providers.dart';

class EquipmentDetails extends ConsumerWidget {
  final String equipmentID;

  const EquipmentDetails({Key? key, required this.equipmentID})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final equipmentList = ref.watch(equipmentStreamProvider);

    return Column(
      children: [
        BackButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
        Expanded(
          child: equipmentList.when(
              error: (error, stackTrace) => Text(error.toString()),
              loading: () => const CircularProgressIndicator.adaptive(),
              data: (data) {
                Equipment equipment = data.singleWhere((element) => element.id == equipmentID);
                List<Category> categoryList = Data.getCategoriyListFromID(
                    pList: Data.categories,
                    pResult: [],
                    categoryID: equipment.category);

                return ListView(
                  children: [
                    Text('brand: ${equipment.brand}'),
                    Text('name: ${equipment.name}'),
                    Text('id: ${equipment.id}'),
                    Text('count: ${equipment.count}'),
                    Text('uvp: ${equipment.uvp}'),
                    Text('price: ${equipment.price}'),
                    Text('purchaseDate: ${equipment.purchaseDate}'),
                    Text('weight: ${equipment.weight}'),
                    Text('status: ${equipment.status}'),
                    Text('size: ${equipment.size}'),
                    Text('sports: ${equipment.sports}'),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('category:'),
                        for (var category in categoryList) Text(category.name),
                      ],
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          bool? confirmDelete =
                              await CustomDialog.showCustomConfirmationDialog(
                                  context: context,
                                  description: "Wirklich löschen?");
                          if (confirmDelete ?? false) {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(Auth().user?.uid)
                                .collection('equipment')
                                .doc(equipment.id)
                                .delete()
                                .then((value) => context.pop());
                          }
                        },
                        child: const Text('delete')),
                    ElevatedButton(
                        onPressed: () {
                          context.push('/equipment/edit', extra: equipment);
                        },
                        child: const Text('edit')),
                  ],
                );
              }),
        ),
      ],
    );
  }
}
