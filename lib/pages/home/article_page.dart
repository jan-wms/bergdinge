import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../custom_widgets/custom_close_button.dart';
import '../../data/design.dart';

class ArticlePage extends ConsumerStatefulWidget {
  final int index;

  const ArticlePage({Key? key, required this.index}) : super(key: key);

  @override
  ConsumerState<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends ConsumerState<ArticlePage> {
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
    final images = <String>[
      'assets/items/landscape.jpg',
      'assets/items/backpack.jpg',
      'assets/items/landscape2.jpg',
    ];

    return DismissiblePage(
      onDismissed: () {
        ref.read(_closeButtonVisibilityProvider.notifier).state = false;
        context.pop();
      },
      minRadius: 0.0,
      maxRadius: 100.0,
      direction: DismissiblePageDismissDirection.down,
      child: Scaffold(
          body: Stack(
        children: [
          SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  Hero(
                    tag: widget.index.toString(),
                    child: Material(
                        color: Colors.transparent,
                        child: Image.asset(images[widget.index])),
                  ),
                  Container(
                    padding:
                        Design.pagePadding.copyWith(top: 15.0, bottom: 40.0),
                    alignment: Alignment.centerLeft,
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rucksack packen',
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Ratgeber',
                          style: TextStyle(
                              fontSize: 17,
                              color: Colors.black54,
                              fontWeight: FontWeight.w600),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 30.0),
                          child: Text(
                              'Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: safeareaPadding.right + 5,
            top: safeareaPadding.top + 5,
            child: AnimatedOpacity(
              opacity: ref.watch(_closeButtonVisibilityProvider) ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 100),
              child: CustomCloseButton(
                onPressed: () {
                  ref.read(_closeButtonVisibilityProvider.notifier).state =
                      false;
                },
              ),
            ),
          ),
        ],
      )),
    );
  }
}
