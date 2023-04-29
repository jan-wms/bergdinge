import 'package:equipment_app/data/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EquipmentPage extends ConsumerWidget {
  const EquipmentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final equipmentList = ref.watch(equipmentStreamProvider);

    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Meine Ausrüstung',
            ),
            const TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
              ),
            ),
            ElevatedButton(
                onPressed: () => context.push('/equipment/edit'),
                child: const Text('Gegenstand hinzufügen')),
            Expanded(
                child: equipmentList.when(
              error: (error, stackTrace) => Text(error.toString()),
              loading: () => const CircularProgressIndicator.adaptive(),
              data: (data) {
                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final equipment = data[index];
                    return ListTile(
                      title: Text('${equipment.brand!} ${equipment.name}'),
                      subtitle: Text(equipment.size ?? ''),
                      onTap: () {
                        context.push('/equipment/details', extra: equipment);
                      },
                    );
                  },
                );
              },
            ))
          ],
        ),
    );
  }
}
