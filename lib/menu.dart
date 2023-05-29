import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equipment_app/firebase/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Menu extends StatefulWidget {
  const Menu({Key? key}) : super(key: key);

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black12,
      child: ListView(
        children: [
          FutureBuilder(
              future: FirebaseStorage.instance
                  .ref()
                  .child("users/${Auth().user!.uid}/profile.jpg")
                  .getData(),
              builder: (context, snapshot) {
                if(snapshot.hasError || !snapshot.hasData) return Text(snapshot.error.toString());

                return CircleAvatar(
                  radius: 48,
                  backgroundImage: Image.memory(snapshot.data!).image,
                );
              }),
          FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection("users")
                  .doc(Auth().user!.uid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.hasError || !snapshot.hasData) {
                  return const CircularProgressIndicator.adaptive();
                }
                return Text(snapshot.data?['name'] ?? 'error name');
              }),
          ListTile(
            title: const Text('Entdecken'),
            onTap: () => GoRouter.of(context).go('/'),
          ),
          ListTile(
            title: const Text('Packlisten'),
            onTap: () => GoRouter.of(context).go('/packing_plan'),
          ),
          ListTile(
            title: const Text('Ausrüstung'),
            onTap: () => GoRouter.of(context).go('/equipment'),
          ),
          ListTile(
            title: const Text('Einstellungen'),
            onTap: () => GoRouter.of(context).go('/settings'),
          ),
          if(kIsWeb) ListTile(
            title: const Text('Logout'),
            onTap: () => Auth().signOut(),
          ),
        ],
      ),
    );
  }
}
