import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equipment_app/custom_widgets/custom_dialog.dart';
import 'package:equipment_app/data_models/equipment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../custom_widgets/custom_back_button.dart';
import '../../data/data.dart';
import '../../firebase/firebase_auth.dart';
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
        const CustomBackButton(),
        Expanded(
          child: equipmentList.when(
              error: (error, stackTrace) => Text(error.toString()),
              loading: () => const CircularProgressIndicator.adaptive(),
              data: (data) {
                Equipment equipment = data.singleWhere((element) => element.id == equipmentID);

                return ListView(
                  children: [
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: Hero(tag: 'image$equipmentID',
                          child: Image.asset('assets/items/map.png')),
                    ),
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
                    Text('category: ${equipment.category}'),
                    Text('category: ${Data.getCategoryNames(equipment.category)}'),
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
