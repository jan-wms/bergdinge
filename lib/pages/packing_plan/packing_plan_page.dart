import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data_models/packing_plan.dart';
import '../../firebase/firebase_auth.dart';

class PackingPlanPage extends StatefulWidget {
  const PackingPlanPage({Key? key}) : super(key: key);

  @override
  State<PackingPlanPage> createState() => _PackingPlanPageState();
}

class _PackingPlanPageState extends State<PackingPlanPage> {
  final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
      .collection('users')
      .doc(Auth().user?.uid)
      .collection('packing_plan')
      .withConverter(
    fromFirestore: PackingPlan.fromFirestore,
    toFirestore: (PackingPlan p, _) => p.toMap(),
  )
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'Meine Packlisten',
          ),
          ElevatedButton(
              onPressed: () => context.push('/packing_plan/edit'),
              child: const Text('Packliste erstellen')),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
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
                    PackingPlan p = document.data() as PackingPlan;
                    return ListTile(
                      title: Text(p.name),
                      subtitle: Text(p.sports.toString()),
                      onTap: () {
                        context.push('/packing_plan/details', extra: p);
                      },
                    );
                  })
                      .toList()
                      .cast(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}