import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:equipment_app/custom_widgets/custom_dialog.dart';
import 'package:equipment_app/data_models/equipment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../custom_widgets/custom_close_button.dart';
import '../../data/data.dart';
import '../../data/design.dart';
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
      child: Scaffold(
        body: equipmentList.when(
            error: (error, stackTrace) => Text(error.toString()),
            loading: () => const CircularProgressIndicator.adaptive(),
            data: (data) {
              Equipment equipment =
              data.singleWhere((element) => element.id == equipmentID);

              return SafeArea(
                top: false,
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Container(
                        color: Colors.white,
                        child: Column(
                              children: [
                                Hero(
                                  tag: 'image${equipment.id}',
                                  child: Container(
                                    color: Design.colors[3],
                                    height: 300.0,
                                    width: double.infinity,
                                    child: SafeArea(
                                      child: Image.asset('assets/items/map.png'),
                                    ),
                                  ),
                                ),
                                Text('${equipment.brand!} ${equipment.name}'),
                                Text(Data
                                    .getCategoryNames(equipment.category)
                                    .last),
                                Row(
                                  children: [
                                    Text('weight: ${equipment.weight}'),
                                    Text('size: ${equipment.size}'),
                                    Text('count: ${equipment.count}'),
                                  ],
                                ),
                                Text('uvp: ${equipment.uvp}'),
                                Text('price: ${equipment.price}'),
                                Text('purchaseDate: ${equipment.purchaseDate}'),
                                Text('status: ${equipment.status}'),
                                Text(
                                    'category: ${Data.getCategoryNames(
                                        equipment.category)}'),

                                Row(
                                  children: [
                                    OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor:
                                          const Color.fromRGBO(255, 194, 194, 1.0),
                                          side: const BorderSide(color: Colors.red),
                                          shape: const RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.all(Radius.circular(10))),
                                        ),
                                        onPressed: () async {
                                          bool? confirmDelete = await CustomDialog
                                              .showCustomConfirmationDialog(
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
                                        child: const Text(
                                          'Löschen',
                                          style: TextStyle(color: Colors.red, fontSize: 17),
                                        )),
                                    TextButton(
                                        style: TextButton.styleFrom(
                                          foregroundColor: Design.colors[1],
                                          backgroundColor:
                                          const Color.fromRGBO(224, 255, 214, 1.0),
                                          shape: const RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.all(Radius.circular(10))),
                                        ),
                                        onPressed: () =>
                                            context.push('/equipment/edit',
                                                extra: equipment),
                                        child: const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.edit_rounded),
                                            Padding(
                                              padding: EdgeInsets.only(left: 10.0),
                                              child: Text(
                                                'Bearbeiten',
                                                style: TextStyle(fontSize: 17),
                                              ),
                                            ),
                                          ],
                                        )),
                                  ],
                                ),
                                Container(
                                  height: 400,
                                ),
                                const Divider(),
                                //TODO copy to clipboard
                                GestureDetector(
                                  onLongPress: () {},
                                  child: Text(
                                    equipment.id,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                      ),
                    ),
                    const Positioned(right: 0.0, top: 0.0,child: CustomCloseButton(),),
                  ],
                ),
              );
            }),
      ),
    );
  }
}
