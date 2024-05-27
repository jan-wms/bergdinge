import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:equipment_app/custom_widgets/custom_dialog.dart';
import 'package:equipment_app/data_models/equipment.dart';
import 'package:equipment_app/parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../custom_widgets/custom_close_button.dart';
import '../../data/data.dart';
import '../../data/design.dart';
import '../../firebase/firebase_auth.dart';
import 'package:equipment_app/data/providers.dart';

import 'equipment_edit.dart';

class EquipmentDetails extends ConsumerStatefulWidget {
  final String equipmentID;

  const EquipmentDetails({super.key, required this.equipmentID});

  @override
  ConsumerState<EquipmentDetails> createState() => _EquipmentDetailsState();
}

class _EquipmentDetailsState extends ConsumerState<EquipmentDetails> {
  final _closeButtonVisibilityProvider =
  StateProvider.autoDispose<bool>((ref) => false);

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      ref
          .read(_closeButtonVisibilityProvider.notifier)
          .state = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final safeareaPadding = MediaQuery
        .of(context)
        .padding;
    final equipmentList = ref.watch(equipmentStreamProvider);
    bool isDesktop = MediaQuery
        .of(context)
        .size
        .width > 700;

    return DismissiblePage(
      onDismissed: () {
        ref
            .read(_closeButtonVisibilityProvider.notifier)
            .state = false;
        context.pop();
      },
      minRadius: 0.0,
      maxRadius: 100.0,
      direction: DismissiblePageDismissDirection.down,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: equipmentList.when(
            error: (error, stackTrace) => Text(error.toString()),
            loading: () => const CircularProgressIndicator(),
            data: (data) {
              Equipment equipment = data.singleWhereOrNull(
                      (element) => element.id == widget.equipmentID) ??
                  Equipment(
                    name: '',
                    weight: 0,
                    status: EquipmentStatus.disabled,
                    category: '',
                    count: 0,
                    id: '',
                    brand: '',
                  );
              return Stack(
                children: [
                  CustomScrollView(
                      scrollDirection:
                      (isDesktop) ? Axis.horizontal : Axis.vertical,
                      physics: (isDesktop)
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
                                padding: (isDesktop)
                                    ? EdgeInsets.symmetric(
                                    horizontal: MediaQuery
                                        .of(context)
                                        .size
                                        .width *
                                        0.05,
                                    vertical: MediaQuery
                                        .of(context)
                                        .size
                                        .height *
                                        0.05)
                                    .add(EdgeInsets.only(
                                    left: safeareaPadding.left))
                                    : EdgeInsets.zero,
                                constraints: (isDesktop)
                                    ? BoxConstraints(
                                  maxHeight:
                                  MediaQuery
                                      .of(context)
                                      .size
                                      .height,
                                  maxWidth:
                                  MediaQuery
                                      .of(context)
                                      .size
                                      .width *
                                      0.5,
                                )
                                    : null,
                                child: AspectRatio(
                                  aspectRatio: (isDesktop)
                                      ? 1
                                      : MediaQuery
                                      .of(context)
                                      .size
                                      .width / 300,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Design.colors[0],
                                      borderRadius: (isDesktop)
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
                                              constraints: (isDesktop)
                                                  ? const BoxConstraints(
                                                maxWidth: 200.0,
                                              )
                                                  : null,
                                              child: getImagefromCategory(category: equipment.category),
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
                                  width: (isDesktop)
                                      ? MediaQuery
                                      .of(context)
                                      .size
                                      .width * 0.5
                                      : null,
                                  padding: Design.pagePadding.copyWith(
                                      right: (isDesktop)
                                          ? (MediaQuery
                                          .of(context)
                                          .size
                                          .width *
                                          0.05) +
                                          safeareaPadding.right
                                          : null,
                                      top: (isDesktop)
                                          ? MediaQuery
                                          .of(context)
                                          .size
                                          .height *
                                          0.05
                                          : 15,
                                      bottom: safeareaPadding.bottom + 30.0),
                                  alignment: Alignment.centerLeft,
                                  child: Column(children: [
                                    Container(
                                      padding: const EdgeInsets.only(
                                          top: 15.0, bottom: 40.0),
                                      alignment: Alignment.centerLeft,
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${equipment.brand!} ${equipment
                                                .name}',
                                            style: const TextStyle(
                                                fontSize: 25,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          Text(
                                            equipment.category.isEmpty
                                                ? ''
                                                : Data.getCategoryNames(
                                                equipment.category)
                                                .lastWhere((element) =>
                                            !element
                                                .toLowerCase()
                                                .contains('sonstige')),
                                            style: const TextStyle(
                                                fontSize: 17,
                                                color: Colors.black54,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Wrap(
                                      spacing: 10.0,
                                      runSpacing: 10.0,
                                      alignment: WrapAlignment.center,
                                      children: [
                                        _CustomBox(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment
                                                .center,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 10.0),
                                                child: Icon(
                                                  Icons.scale_rounded,
                                                  color: Design.colors[0],
                                                ),
                                              ),
                                              Text(
                                                '${equipment.weight}g',
                                                style: TextStyle(
                                                    fontSize: 25,
                                                    color: Design.colors[0],
                                                    fontWeight: FontWeight
                                                        .w600),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if(equipment.size != null)
                                        _CustomBox(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 10.0),
                                                child: Icon(
                                                  Icons.open_in_full_rounded,
                                                  color: Design.colors[0],
                                                ),
                                              ),
                                              Text(
                                                equipment.size!,
                                                style: TextStyle(
                                                    color: Design.colors[0],
                                                    fontSize: 25,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                        _CustomBox(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            crossAxisAlignment:
                                            CrossAxisAlignment.baseline,
                                            textBaseline: TextBaseline
                                                .ideographic,
                                            children: [
                                              Padding(
                                                padding:
                                                const EdgeInsets.only(right: 3),
                                                child: Text(
                                                  equipment.count.toString(),
                                                  style: TextStyle(
                                                      fontSize: 25,
                                                      fontWeight: FontWeight
                                                          .bold,
                                                      color: Design.colors[0]),
                                                ),
                                              ),
                                              const Text(
                                                'x',
                                                style: TextStyle(
                                                    color: Colors.black38,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight
                                                        .w600),
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
                                                  '${parsePrice(
                                                      (equipment.price ??
                                                          equipment.uvp)!)}€',
                                                  style: TextStyle(
                                                    fontSize: 25,
                                                    fontWeight: FontWeight.w600,
                                                    color: Design.colors[0],
                                                  ),
                                                ),
                                                if (equipment.price !=
                                                    equipment.uvp &&
                                                    equipment.price != null &&
                                                    equipment.uvp != null)
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .only(
                                                        left: 10.0),
                                                    child: Text(
                                                      '${parsePrice(
                                                          equipment.uvp!)}€',
                                                      style: TextStyle(
                                                          fontWeight: FontWeight
                                                              .w600,
                                                          fontSize: 19,
                                                          color: Colors.black
                                                              .withOpacity(0.6),
                                                          decoration: TextDecoration
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
                                                  child: Icon(
                                                      Icons.date_range_rounded),
                                                ),
                                                Text(
                                                  parseDate(
                                                      equipment.purchaseDate!),
                                                  style: TextStyle(
                                                    fontSize: 25,
                                                    fontWeight: FontWeight.w600,
                                                    color: Design.colors[0],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                    if (isDesktop)
                                      Padding(
                                          padding: const EdgeInsets.only(
                                              top: 40.0),
                                          child: _Actions(
                                              equipment: equipment)),
                                  ]),
                                )),
                          ),
                        ),
                        if (!isDesktop)
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
                      opacity:
                      ref.watch(_closeButtonVisibilityProvider) ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 100),
                      child: CustomCloseButton(
                        onPressed: () {
                          ref
                              .read(_closeButtonVisibilityProvider.notifier)
                              .state = false;
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
              offset: const Offset(0, 7),
              blurRadius: 10,
              color: Design.colors[1].withOpacity(0.4),
            )
          ],
        ),
        child: child);
  }
}

class _Actions extends StatelessWidget {
  final Equipment equipment;

  const _Actions({required this.equipment});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
            backgroundColor: const Color.fromRGBO(255, 230, 230, 1.0),
          ),
          onPressed: () async {
            bool? confirmDelete =
            await CustomDialog.showCustomConfirmationDialog(
                type: ConfirmType.confirmDelete,
                context: context,
                description:
                'Möchtest du diesen Gegenstand wirklich löschen?');
            if (confirmDelete ?? false) {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(Auth().user?.uid)
                  .collection('equipment')
                  .doc(equipment.id)
                  .delete()
                  .then((value) => context.pop());
            }
          },
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
            foregroundColor: Design.colors[0],
            backgroundColor: const Color.fromRGBO(220, 245, 220, 1.0),
          ),
          onPressed: () =>
              CustomDialog.showCustomModal(
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
