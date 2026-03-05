import 'package:bergdinge/models/packing_plan_details_data.dart';
import 'package:bergdinge/screens/packing_plan/details/tip_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../data/design.dart';
import '../../../data/tips_data.dart';
import '../../../firebase/firebase_auth.dart';
import '../../../models/packing_plan.dart';
import '../../../models/packing_plan_location.dart';
import '../../../models/tip.dart';
import '../../../widgets/custom_dialog.dart';
import '../../../widgets/overlay_close_button.dart';
import '../../equipment/equipment_list.dart';
import 'edit_item.dart';

class ToolsSection extends StatefulWidget {
  final PackingPlanDetailsData data;

  const ToolsSection({super.key, required this.data});

  @override
  State<ToolsSection> createState() =>
      _ToolsSectionState();
}

class _ToolsSectionState extends State<ToolsSection> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController controllerNotes =
  TextEditingController(text: widget.data.packingPlan.notes ?? '');

  Future<void> updateNotes() async {
    if (_formKey.currentState!.validate()) {
      DocumentReference ref = FirebaseFirestore.instance
          .collection('users')
          .doc(Auth().user?.uid)
          .collection('packing_plan')
          .doc(widget.data.packingPlan.id);

      ref.update({"notes": controllerNotes.text});
    }
  }

  Future<void> showTips() async {
    CustomDialog.showCustomModal<void>(
        context: context,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 600.0,
          ),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 20.0, bottom: 10.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      'Tipps',
                      style:
                      TextStyle(fontSize: 21, fontWeight: FontWeight.w600),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OverlayCloseButton(),
                    ),
                  ],
                ),
              ),
              const Divider(
                indent: 15,
                endIndent: 15,
                height: 1,
                color: Colors.grey,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: TipsData.tips
                      .where((element) =>
                      element.isRelevant(widget.data.packingPlan))
                      .length,
                  itemBuilder: (context, index) {
                    Tip tip = TipsData.tips
                        .where((element) =>
                        element.isRelevant(widget.data.packingPlan))
                        .toList()[index];
                    return Padding(
                      padding: index == 0
                          ? const EdgeInsets.only(top: 10.0)
                          : EdgeInsets.zero,
                      child: TipCard(
                        tip: tip,
                        isConditionMet: tip.isConditionMet(
                            widget.data.items, widget.data.equipment),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ));
  }

  Future<void> addItem() async {
    CustomDialog.showCustomModal(
        context: context,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 700.0,
          ),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 20.0, bottom: 10.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      'Ausrüstung hinzufügen',
                      style:
                      TextStyle(fontSize: 21, fontWeight: FontWeight.w600),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OverlayCloseButton(),
                    ),
                  ],
                ),
              ),
              const Divider(
                indent: 15,
                endIndent: 15,
                height: 1,
                color: Colors.grey,
              ),
              Expanded(
                  child: CustomScrollView(
                    slivers: [
                      EquipmentList(
                        packingPlanId: widget.data.packingPlan.id,
                        onItemClick: (equipmentId) {
                          PackingPlanLocation? loc = widget.data.items
                              .where((e) => e.equipmentId == equipmentId)
                              .firstOrNull
                              ?.location;
                          CustomDialog.showCustomDialog(
                            barrierDismissible: true,
                            context: context,
                            child: EditItem(
                                location: loc,
                                equipmentId: equipmentId,
                                packingPlanId: widget.data.packingPlan.id),
                          );
                        },
                      ),
                    ],
                  )),
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final isWide =
        MediaQuery
            .of(context)
            .size
            .width > Design.wideScreenBreakpoint;
    return Container(
      margin: Design.pagePadding.copyWith(top: 15.0, bottom: 15.0),
      padding: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 4,
            blurRadius: 10,
            offset: const Offset(2, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              right: 0.0,
              bottom: 15.0,
            ),
            child: Wrap(
              runSpacing: 13.0,
              spacing: 13.0,
              alignment: WrapAlignment.center,
              children: [
                for (var sport in widget.data.packingPlan.sports)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 13.0, vertical: 9.0),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(218, 231, 208, 1),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Text(
                      sport,
                      style: TextStyle(
                        fontSize: 15.0,
                        color: Design.darkGreen,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Form(
            key: _formKey,
            child: TextFormField(
              autofocus: false,
              validator: (value) => PackingPlan.validateNotes(value),
              controller: controllerNotes,
              decoration: const InputDecoration(
                labelText: 'Notizen',
                alignLabelWithHint: true,
              ),
              minLines: isWide ? 6 : 2,
              maxLines: 6,
              keyboardType: TextInputType.multiline,
              onTapOutside: (value) {
                FocusScope.of(context).unfocus();
                updateNotes();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: Wrap(
              spacing: 20,
              runSpacing: 10,
              children: [
                _Button(
                    text: 'Tipps',
                    icon: Icons.lightbulb_rounded,
                    onPressed: showTips),
                _Button(
                    text: 'Ausrüstung',
                    icon: Icons.add_rounded,
                    onPressed: addItem),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _Button extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const _Button(
      {required this.text, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(170, 40),
        padding: EdgeInsets.zero,
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromRGBO(35, 63, 33, 1.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Icon(icon, size: 25),
            ),
            Text(
              text,
              style: TextStyle(fontSize: 17),
            ),
          ],
        ),
      ),
    );
  }
}
