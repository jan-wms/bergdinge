import 'package:equipment_app/custom_widgets/custom_appbar.dart';
import 'package:equipment_app/custom_widgets/custom_dialog.dart';
import 'package:equipment_app/pages/equipment/equipment_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'equipment_edit.dart';

final equipmentSearchProvider = StateProvider.autoDispose<String>(
  (ref) => '',
);

class EquipmentPage extends ConsumerWidget {
  const EquipmentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      top: false,
      child: CustomScrollView(
        slivers: <Widget>[
          CustomAppBar(
            searchInitialValue: ref.watch(equipmentSearchProvider),
            title: 'Ausrüstung',
            icon: Icons.terrain,
            onButtonPressed: () => CustomDialog.showCustomModal(
                context: context, child: const EquipmentEdit()),
            onSearchChanged: (value) => ref
                .read(equipmentSearchProvider.notifier)
                .update((state) => value),
          ),
          EquipmentList(
            onItemClick: (equipmentId) =>
                context.push('/equipment/details', extra: equipmentId),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 20.0)),
        ],
      ),
    );
  }
}
