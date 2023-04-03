import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equipment_app/data_models/equipment.dart';
import 'package:equipment_app/firebase/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EquipmentPage extends StatefulWidget {
  const EquipmentPage({super.key});

  @override
  State<EquipmentPage> createState() => _EquipmentPageState();
}

class _EquipmentPageState extends State<EquipmentPage> {
  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
      .collection('users')
      .doc(Auth().user?.uid)
      .collection('equipment')
      .withConverter(
        fromFirestore: Equipment.fromFirestore,
        toFirestore: (Equipment e, _) => e.toFirestore(),
      )
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'Meine Ausrüstung',
          ),
          ElevatedButton(
              onPressed: () => context.go('/equipment/edit'),
              child: const Text('Gegenstand hinzufügen')),
          StreamBuilder<QuerySnapshot>(
            stream: _usersStream,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator.adaptive();
              }
              return ListView(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                children: snapshot.data!.docs
                    .map((DocumentSnapshot document) {
                      Equipment e = document.data() as Equipment;
                      return ListTile(
                        title: Text('${e.brand!} ${e.name}'),
                        subtitle: Text(e.size ?? ''),
                      );
                    })
                    .toList()
                    .cast(),
              );
            },
          ),
        ],
      ),
    );
  }
}
