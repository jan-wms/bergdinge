import 'package:bergdinge/data/category_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:bergdinge/widgets/custom_dialog.dart';
import 'package:bergdinge/models/equipment.dart';
import 'package:bergdinge/utilities/parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/overlay_close_button.dart';
import '../../data/design.dart';
import '../../firebase/firebase_auth.dart';
import 'package:bergdinge/firebase/firebase_data_providers.dart';

import 'equipment_edit.dart';

class EquipmentDetails extends ConsumerStatefulWidget {
  final String equipmentId;
  final int transitionDelay;

  const EquipmentDetails(
      {super.key, required this.transitionDelay, required this.equipmentId});

  @override
  ConsumerState<EquipmentDetails> createState() => _EquipmentDetailsState();
}

class _EquipmentDetailsState extends ConsumerState<EquipmentDetails> {
  bool _showCloseButton = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.transitionDelay), () {
      if (mounted) {
        setState(() {
          _showCloseButton = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final safeareaPadding = MediaQuery.of(context).padding;
    final equipmentList = ref.watch(equipmentStreamProvider);
    final bool isWide = MediaQuery.of(context).size.width > 700;

    return DismissiblePage(
      onDismissed: () {
        setState(() {
          _showCloseButton = false;
        });
        context.pop();
      },
      minRadius: 0.0,
      maxRadius: 100.0,
      direction: DismissiblePageDismissDirection.down,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: equipmentList.when(
            error: (error, stackTrace) => Center(child: Text(error.toString())),
            loading: () => const CircularProgressIndicator(),
            data: (data) {
              Equipment equipment = data.singleWhereOrNull(
                      (element) => element.id == widget.equipmentId) ??
                  Equipment(
                      name: '', weight: 0, category: '', count: 0, id: '');
              return Stack(
                children: [
                  CustomScrollView(
                      scrollDirection:
                          (isWide) ? Axis.horizontal : Axis.vertical,
                      physics: (isWide)
                          ? const NeverScrollableScrollPhysics()
                          : const ClampingScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Hero(
                            tag: 'image${equipment.id}',
                            child: Material(
                              color: Colors.transparent,
                              child: Container(
                                alignment: Alignment.center,
                                padding: (isWide)
                                    ? EdgeInsets.symmetric(
                                            horizontal: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.05,
                                            vertical: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.05)
                                        .add(EdgeInsets.only(
                                            left: safeareaPadding.left))
                                    : EdgeInsets.zero,
                                constraints: (isWide)
                                    ? BoxConstraints(
                                        maxHeight:
                                            MediaQuery.of(context).size.height,
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.5,
                                      )
                                    : null,
                                child: AspectRatio(
                                  aspectRatio: (isWide)
                                      ? 1
                                      : MediaQuery.of(context).size.width / 300,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Design.darkGreen,
                                      borderRadius: (isWide)
                                          ? BorderRadius.circular(20.0)
                                          : BorderRadius.zero,
                                    ),
                                    height: 300.0,
                                    width: double.infinity,
                                    child: SafeArea(
                                      child: Padding(
                                        padding: const EdgeInsets.all(30.0),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Container(
                                            constraints: (isWide)
                                                ? const BoxConstraints(
                                                    maxWidth: 200.0,
                                                  )
                                                : null,
                                            child: equipment.category.isNotEmpty
                                                ? CategoryData
                                                    .getImagefromCategory(
                                                        category:
                                                            equipment.category)
                                                : const SizedBox(
                                                    width: 1.0,
                                                    height: 1.0,
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Align(
                            alignment: Alignment.center,
                            child: SingleChildScrollView(
                                child: Container(
                              width: (isWide)
                                  ? MediaQuery.of(context).size.width * 0.5
                                  : null,
                              padding: Design.pagePadding.copyWith(
                                  right: (isWide)
                                      ? (MediaQuery.of(context).size.width *
                                              0.05) +
                                          safeareaPadding.right
                                      : null,
                                  top: (isWide)
                                      ? MediaQuery.of(context).size.height *
                                          0.05
                                      : 15,
                                  bottom: safeareaPadding.bottom + 30.0),
                              alignment: Alignment.centerLeft,
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(
                                          top: 15.0, bottom: 40.0),
                                      alignment: Alignment.centerLeft,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${(equipment.brand?.isNotEmpty ?? false) ? '${equipment.brand} ' : ''}${equipment.name}',
                                            style: const TextStyle(
                                                fontSize: 25,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          Text(
                                            equipment.category.isEmpty
                                                ? ''
                                                : CategoryData
                                                        .flatMapCategories(
                                                            equipment.category)
                                                    .lastWhere((element) =>
                                                        !element.name
                                                            .toLowerCase()
                                                            .contains(
                                                                'sonstige'))
                                                    .name,
                                            style: const TextStyle(
                                                fontSize: 17,
                                                color: Colors.black54,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (equipment.category != '3.0')
                                      Wrap(
                                        spacing: 10.0,
                                        runSpacing: 10.0,
                                        alignment: WrapAlignment.start,
                                        children: [
                                          _CustomBox(
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 10.0),
                                                  child: Icon(
                                                    Icons.scale_rounded,
                                                    color: Design.darkGreen,
                                                  ),
                                                ),
                                                Text(
                                                  '${equipment.weight} g',
                                                  style: TextStyle(
                                                      fontSize: 25,
                                                      color: Design.darkGreen,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (equipment.size != null &&
                                              equipment.size!.isNotEmpty)
                                            _CustomBox(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 10.0),
                                                    child: Icon(
                                                      Icons
                                                          .open_in_full_rounded,
                                                      color: Design.darkGreen,
                                                    ),
                                                  ),
                                                  Text(
                                                    equipment.size!,
                                                    style: TextStyle(
                                                        color: Design.darkGreen,
                                                        fontSize: 25,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          if (equipment.count > 1)
                                            _CustomBox(
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.baseline,
                                                textBaseline:
                                                    TextBaseline.ideographic,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 3),
                                                    child: Text(
                                                      equipment.count
                                                          .toString(),
                                                      style: TextStyle(
                                                          fontSize: 25,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Design.darkGreen),
                                                    ),
                                                  ),
                                                  const Text(
                                                    'x',
                                                    style: TextStyle(
                                                        color: Colors.black38,
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          if (equipment.price != null ||
                                              equipment.uvp != null)
                                            _CustomBox(
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    '${Parser.stringFromDoublePrice((equipment.price ?? equipment.uvp)!)}€',
                                                    style: TextStyle(
                                                      fontSize: 25,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Design.darkGreen,
                                                    ),
                                                  ),
                                                  if (equipment.price !=
                                                          equipment.uvp &&
                                                      equipment.price != null &&
                                                      equipment.uvp != null)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10.0),
                                                      child: Text(
                                                        '${Parser.stringFromDoublePrice(equipment.uvp!)}€',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 19,
                                                            color: Colors.black
                                                                .withValues(
                                                                    alpha: 0.6),
                                                            decoration:
                                                                TextDecoration
                                                                    .lineThrough),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          if (equipment.purchaseDate != null)
                                            _CustomBox(
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                        right: 10.0),
                                                    child: Icon(Icons
                                                        .date_range_rounded),
                                                  ),
                                                  Text(
                                                    Parser.stringFromDateTime(
                                                        equipment
                                                            .purchaseDate!),
                                                    style: TextStyle(
                                                      fontSize: 25,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Design.darkGreen,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    if (isWide)
                                      Padding(
                                          padding:
                                              const EdgeInsets.only(top: 60.0),
                                          child:
                                              _Actions(equipment: equipment)),
                                  ]),
                            )),
                          ),
                        ),
                        if (!isWide)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Container(
                              alignment: Alignment.bottomCenter,
                              padding: EdgeInsets.only(
                                  bottom: safeareaPadding.bottom + 30.0,
                                  top: 20.0),
                              width: double.infinity,
                              child: _Actions(equipment: equipment),
                            ),
                          ),
                      ]),
                  Positioned(
                    right: safeareaPadding.right + 5,
                    top: safeareaPadding.top + 5,
                    child: AnimatedOpacity(
                      opacity: _showCloseButton ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 100),
                      child: OverlayCloseButton(
                        onPressed: () {
                          setState(() {
                            _showCloseButton = false;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }
}

class _CustomBox extends StatelessWidget {
  final Widget child;

  const _CustomBox({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: const BoxConstraints(
          minWidth: 100.0,
        ),
        padding: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 3),
              blurRadius: 7,
              color: Colors.black26.withValues(alpha: 0.4),
            )
          ],
        ),
        child: child);
  }
}

class _Actions extends StatelessWidget {
  final Equipment equipment;

  const _Actions({required this.equipment});

  Future<void> delete(BuildContext context) async {
    bool? confirmDelete = await CustomDialog.showCustomConfirmationDialog(
        type: ConfirmType.confirmDelete,
        context: context,
        description:
            'Dieser Gegenstand wird auch aus allen Packlisten gelöscht.');
    if (confirmDelete ?? false) {
      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('users').doc(Auth().user?.uid);

      // Delete from packing plans
      final packingPlanSnapshot =
          await userDoc.collection('packing_plan').get();

      for (var doc in packingPlanSnapshot.docs) {
        final itemSnapshot = await doc.reference
            .collection('items')
            .where('equipmentId', isEqualTo: equipment.id)
            .get();
        for (var itemDoc in itemSnapshot.docs) {
          await itemDoc.reference.delete();
        }
      }

      // Delete equipment
      await userDoc.collection('equipment').doc(equipment.id).delete();

      if (context.mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isWide = MediaQuery.of(context).size.width > 700;

    return Row(
      mainAxisAlignment:
          isWide ? MainAxisAlignment.start : MainAxisAlignment.center,
      children: [
        IconButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
            backgroundColor: const Color.fromRGBO(255, 230, 230, 1.0),
          ),
          onPressed: () => delete(context),
          icon: const Icon(
            Icons.delete_rounded,
            size: 35,
          ),
        ),
        const SizedBox(
          width: 20.0,
          height: 20.0,
        ),
        IconButton(
          style: TextButton.styleFrom(
            foregroundColor: Design.darkGreen,
            backgroundColor: const Color.fromRGBO(220, 245, 220, 1.0),
          ),
          onPressed: () => CustomDialog.showCustomModal(
              context: context, child: EquipmentEdit(equipment: equipment)),
          icon: const Icon(
            Icons.edit_rounded,
            size: 35,
          ),
        ),
      ],
    );
  }
}
