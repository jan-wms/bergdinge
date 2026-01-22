import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

import '../../custom_widgets/custom_close_button.dart';
import '../../data/design.dart';
import '../../data_models/article.dart';

class ArticlePage extends ConsumerStatefulWidget {
  final Article article;

  const ArticlePage({super.key, required this.article});

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
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    return DismissiblePage(
      onDismissed: () {
        ref.read(_closeButtonVisibilityProvider.notifier).state = false;
        context.pop();
      },
      minRadius: 0.0,
      maxRadius: 100.0,
      direction: DismissiblePageDismissDirection.down,
      child: Scaffold(
        backgroundColor: Colors.white,
          body: Stack(
        children: [
          CustomScrollView(
            scrollDirection: (isDesktop) ? Axis.horizontal : Axis.vertical,
            physics: (isDesktop) ? const NeverScrollableScrollPhysics() : const ClampingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Hero(
                  tag: widget.article.title.toString(),
                  child: Material(
                      color: Colors.transparent,
                      child: Container(
                        padding: (isDesktop) ? EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.05,
                            vertical:
                                MediaQuery.of(context).size.height * 0.05).add(EdgeInsets.only(left: safeareaPadding.left)) : EdgeInsets.zero,

                        constraints: (isDesktop) ? BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height,
                          maxWidth: MediaQuery.of(context).size.width * 0.5,
                        ) : null,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: ClipRRect(
                              borderRadius: (isDesktop) ? BorderRadius.circular(50.0) : BorderRadius.zero,
                              child: Image(image: widget.article.imageProvider,)),
                        ),
                      )),
                ),
              ),
              SliverToBoxAdapter(
                child: Align(
                    alignment: Alignment.center,
                    child: SingleChildScrollView(
                      physics: (isDesktop) ? null : const NeverScrollableScrollPhysics(),
                      child: Container(
                        width: (isDesktop) ? MediaQuery.of(context).size.width * 0.5 : null,
                        padding: Design.pagePadding.copyWith(
                          right: (isDesktop) ? (MediaQuery.of(context).size.width * 0.05) + safeareaPadding.right : null,
                            top: (isDesktop) ? MediaQuery.of(context).size.height * 0.05 : 15, bottom: safeareaPadding.bottom + 30.0),
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.article.title,
                              style: const TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              widget.article.subTitle,
                              style: const TextStyle(
                                  fontSize: 17,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w600),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 30.0),
                              child: Column(
                                children: widget.article.content,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ),
            ],
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
