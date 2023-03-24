import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equipment_app/firebase/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EquipmentPage extends StatefulWidget {
  const EquipmentPage({super.key});

  @override
  State<EquipmentPage> createState() => _EquipmentPageState();
}

class _EquipmentPageState extends State<EquipmentPage> {
  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('users').doc(Auth().user?.uid).collection('equipment').snapshots();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'Equipment Page',
          ),
          StreamBuilder<QuerySnapshot>(
            stream: _usersStream,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                print(snapshot.error);
                return  Text(snapshot.error.toString());
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text("Loading");
              }

              return ListView(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                children: snapshot.data!.docs
                    .map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;
                      return ListTile(
                        title: Text(data['type']),
                      );
                    })
                    .toList()
                    .cast(),
              );
            },
          ),
          ElevatedButton(
              onPressed: () {
                GoRouter.of(context).go('/');
              },
              child: const Text('go to Homepage'))
        ],
      ),
    );
  }
}
