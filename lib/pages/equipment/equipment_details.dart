import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equipment_app/custom_widgets/custom_dialog.dart';
import 'package:equipment_app/data_models/equipment.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data_models/category.dart';
import '../../firebase/firebase_auth.dart';
import '../../data/data.dart';

class EquipmentDetails extends StatefulWidget {
  final Equipment equipment;

  const EquipmentDetails({Key? key, required this.equipment}) : super(key: key);

  @override
  State<EquipmentDetails> createState() => _EquipmentDetailsState();
}

class _EquipmentDetailsState extends State<EquipmentDetails> {
  late final List<Category> categoryList;

  @override
  void initState() {
    super.initState();
    categoryList = Data.getCategoriyListFromID(
        pList: Data.categories,
        pResult: [],
        categoryID: widget.equipment.category);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BackButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
        Text('brand: ${widget.equipment.brand}'),
        Text('name: ${widget.equipment.name}'),
        Text('id: ${widget.equipment.id}'),
        Text('count: ${widget.equipment.count}'),
        Text('uvp: ${widget.equipment.uvp}'),
        Text('price: ${widget.equipment.price}'),
        Text('purchaseDate: ${widget.equipment.purchaseDate}'),
        Text('weight: ${widget.equipment.weight}'),
        Text('status: ${widget.equipment.status}'),
        Text('size: ${widget.equipment.size}'),
        Text('sports: ${widget.equipment.sports}'),

        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('category:'),
            for (var category in categoryList) Text(category.name),],
        ),
        ElevatedButton(
            onPressed: () async {
              bool? confirmDelete =
                  await CustomDialog.showCustomConfirmationDialog(
                      context: context, description: "Wirklich löschen?");
              if (confirmDelete ?? false) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(Auth().user?.uid)
                    .collection('equipment')
                    .doc(widget.equipment.id)
                    .delete()
                    .then((value) => context.pop());
              }
            },
            child: const Text('delete')),
        ElevatedButton(
            onPressed: () {
              context.push('/equipment/edit', extra: widget.equipment);
            },
            child: const Text('edit')),
      ],
    );
  }
}
