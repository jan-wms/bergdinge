import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/providers.dart';

class PackingPlanPage extends ConsumerWidget {
  const PackingPlanPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packingPlanList = ref.watch(packingPlanStreamProvider);

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
            child: packingPlanList.when(
              error: (error, stackTrace) => Text(error.toString()),
              loading: () => const CircularProgressIndicator.adaptive(),
              data: (data) {
                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final packingPlan = data[index];
                    return ListTile(
                      title: Text(packingPlan.name),
                      subtitle: Text(packingPlan.sports.toString()),
                      onTap: () {
                        context.push('/packing_plan/details', extra: packingPlan);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
