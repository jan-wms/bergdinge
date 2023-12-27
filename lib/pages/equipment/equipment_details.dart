import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dismissible_page/dismissible_page.dart';
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

    return DismissiblePage(
          onDismissed: () {
            context.pop();
          },
      minRadius: 0.0,
      maxRadius: 100.0,
      direction: DismissiblePageDismissDirection.down,
          child: equipmentList.when(
              error: (error, stackTrace) => Text(error.toString()),
              loading: () => const CircularProgressIndicator.adaptive(),
              data: (data) {
                Equipment equipment =
                    data.singleWhere((element) => element.id == equipmentID);

                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        Hero(
                          tag: 'image${equipment.id}',
                          child: Container(
                            color: Colors.greenAccent,
                            height: 300.0,
                            width: double.infinity,
                            padding: const EdgeInsets.only(bottom: 20.0, top: 40.0),
                            child: Column(
                              children: [
                                Expanded( child: Image.asset('assets/items/map.png')
                                ),
                                Text('${equipment.brand!} ${equipment.name}'),
                              ],
                            ),
                          ),
                        ),
                        const CustomBackButton(),
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
                        Text(
                            'category: ${Data.getCategoryNames(equipment.category)}'),
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
                        Container(
                          height: 300,
                        ),
                      ],
                    ),
                  ),
                );
              }),
    );
  }
}
