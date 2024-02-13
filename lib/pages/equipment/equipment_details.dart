import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dismissible_page/dismissible_page.dart';
import 'package:equipment_app/copy_to_clipboard.dart';
import 'package:equipment_app/custom_widgets/custom_dialog.dart';
import 'package:equipment_app/data_models/equipment.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  const EquipmentDetails({Key? key, required this.equipmentID})
      : super(key: key);

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
      ref.read(_closeButtonVisibilityProvider.notifier).state = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final safeareaPadding = MediaQuery.of(context).padding;
    final equipmentList = ref.watch(equipmentStreamProvider);

    return DismissiblePage(
      onDismissed: () {
        ref.read(_closeButtonVisibilityProvider.notifier).state = false;
        context.pop();
      },
      minRadius: 0.0,
      maxRadius: 100.0,
      direction: DismissiblePageDismissDirection.down,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.white, // Android
            statusBarBrightness: Brightness.dark // iOS
            ),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: equipmentList.when(
              error: (error, stackTrace) => Text(error.toString()),
              loading: () => const CircularProgressIndicator.adaptive(),
              data: (data) {
                Equipment equipment = data
                    .singleWhere((element) => element.id == widget.equipmentID);

                return Stack(
                  children: [
                    CustomScrollView(
                        physics: const ClampingScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(
                            child: Hero(
                              tag: 'image${equipment.id}',
                              child: Material(
                                color: Colors.transparent,
                                child: Container(
                                  color: Design.colors[0],
                                  height: 300.0,
                                  width: double.infinity,
                                  child: SafeArea(
                                    child: Padding(
                                      padding: const EdgeInsets.all(30.0),
                                      child:
                                          Image.asset('assets/items/map.png'),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SliverPadding(
                            padding: Design.pagePadding,
                            sliver: SliverList(
                                delegate: SliverChildListDelegate([
                              Container(
                                padding: const EdgeInsets.only(
                                    top: 15.0, bottom: 40.0),
                                alignment: Alignment.centerLeft,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${equipment.brand!} ${equipment.name}',
                                      style: const TextStyle(
                                          fontSize: 25,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      Data.getCategoryNames(equipment.category)
                                          .last,
                                      style: const TextStyle(
                                          fontSize: 17,
                                          color: Colors.black54,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 350,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                      alignment: Alignment.center,
                                      height: 80,
                                      width: 90,
                                      decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      padding: const EdgeInsets.all(15.0),
                                      child: Column(
                                        children: [
                                          Text(
                                            '${equipment.weight}g',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          const Icon(
                                            Icons.scale_rounded,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      height: 80,
                                      width: 90,
                                      padding: const EdgeInsets.all(15.0),
                                      decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      child: Text(
                                        equipment.size ?? '*',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 35,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      height: 80,
                                      width: 90,
                                      padding: const EdgeInsets.all(15.0),
                                      decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.ideographic,
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(right: 5),
                                            child: Text(
                                              equipment.count.toString(),
                                              style: const TextStyle(
                                                  fontSize: 35,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                          ),
                                          const Text(
                                            'x',
                                            style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Text('Originalpreis: ${equipment.uvp}'),
                              Text('Kaufpreis: ${equipment.price}'),
                              Text('Kaufdatum: ${equipment.purchaseDate}'),
                            ])),
                          ),
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Container(
                              alignment: Alignment.bottomCenter,
                              padding: EdgeInsets.only(
                                  bottom: safeareaPadding.bottom + 30.0,
                                  top: 20.0),
                              width: double.infinity,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: const Color.fromRGBO(
                                            255, 194, 194, 1.0),
                                        side:
                                            const BorderSide(color: Colors.red),
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10))),
                                      ),
                                      onPressed: () async {
                                        bool? confirmDelete = await CustomDialog
                                            .showCustomConfirmationDialog(
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
                                      child: const Text(
                                        'Löschen',
                                        style: TextStyle(
                                            color: Colors.red, fontSize: 17),
                                      )),
                                  ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.only(
                                              left: 20.0,
                                              right: 20.0,
                                              top: 10.0,
                                              bottom: 10.0),
                                          foregroundColor: Colors.white,
                                          backgroundColor: Design.colors[1],
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0))),
                                      onPressed: () =>
                                          CustomDialog.showCustomModal(
                                              context: context,
                                              child: EquipmentEdit(
                                                  equipment: equipment)),
                                      child: Container(
                                        alignment: Alignment.center,
                                        height: 30,
                                        width: 105,
                                        child: const Text(
                                          'Bearbeiten',
                                          style: TextStyle(fontSize: 17),
                                        ),
                                      ))
                                ],
                              ),
                            ),
                          ),
                        ]),
                    Positioned(
                      right: safeareaPadding.right + 5,
                      top: safeareaPadding.top + 5,
                      child: AnimatedOpacity(
                        opacity: ref.watch(_closeButtonVisibilityProvider)
                            ? 1.0
                            : 0.0,
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
      ),
    );
  }
}
