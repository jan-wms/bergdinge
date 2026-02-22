import 'package:dismissible_page/dismissible_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

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
  late Future<http.Response> weather;

  Future<http.Response> fetchWeather() async {
    return http.get(Uri.parse(
        'https://s3.eu-central-1.amazonaws.com/app-prod-static.warnwetter.de/v16/alpen_forecast_text_dwms.json'));
  }

  @override
  void initState() {
    super.initState();
    if (widget.article.isWeather) {
      weather = fetchWeather();
    }
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
    bool isDesktop = MediaQuery
        .of(context)
        .size
        .width > 800;

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
          body: Stack(
            children: [
              CustomScrollView(
                scrollDirection: (isDesktop) ? Axis.horizontal : Axis.vertical,
                physics: (isDesktop)
                    ? const NeverScrollableScrollPhysics()
                    : const ClampingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Hero(
                      tag: widget.article.title.toString(),
                      child: Material(
                          color: Colors.transparent,
                          child: Container(
                            padding: (isDesktop)
                                ? EdgeInsets.symmetric(
                                horizontal:
                                MediaQuery
                                    .of(context)
                                    .size
                                    .width *
                                    0.05,
                                vertical:
                                MediaQuery
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
                                  .width * 0.5,
                            )
                                : null,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: ClipRRect(
                                  borderRadius: (isDesktop)
                                      ? BorderRadius.circular(50.0)
                                      : BorderRadius.zero,
                                  child: Image(
                                    image: widget.article.imageProvider,
                                  )),
                            ),
                          )),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Align(
                      alignment: Alignment.center,
                      child: SingleChildScrollView(
                        physics: (isDesktop)
                            ? null
                            : const NeverScrollableScrollPhysics(),
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
                                  .width * 0.05) +
                                  safeareaPadding.right
                                  : null,
                              top: (isDesktop)
                                  ? MediaQuery
                                  .of(context)
                                  .size
                                  .height * 0.05
                                  : 15,
                              bottom: safeareaPadding.bottom + 30.0),
                          alignment: Alignment.centerLeft,
                          child: (!widget.article.isWeather)
                              ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.article.title,
                                style: Design.articleTitleTextStyle,
                              ),
                              Text(
                                widget.article.subTitle,
                                style: Design.articleSubtitleTextStyle,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 30.0),
                                child: Column(
                                  children: [
                                    ...widget.article.content!,
                                    _UrlButton(url: widget.article.url, displayUrl: widget.article.displayUrl)
                                  ],
                                ),
                              ),
                            ],
                          )
                              : FutureBuilder(
                              future: weather,
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  debugPrint('${snapshot.error}');
                                }
                                return Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.article.title,
                                      style: Design.articleTitleTextStyle,
                                    ),
                                    if (!snapshot.hasError &&
                                        !snapshot.hasData) ...[
                                      Shimmer.fromColors(
                                          baseColor: Colors.grey.shade200,
                                          highlightColor:
                                          Colors.grey.shade100,
                                          child: Container(
                                            height: 18.0,
                                            width: 150.0,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                              BorderRadius.circular(
                                                  5.0),
                                            ),
                                          )),
                                      Padding(
                                          padding: const EdgeInsets.only(
                                              top: 30.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment
                                                .start,
                                            children: [
                                              for(int i = 0; i < 8; i++)
                                                Shimmer.fromColors(
                                                  baseColor: Colors.grey
                                                      .shade200,
                                                  highlightColor:
                                                  Colors.grey.shade100,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          4.0),
                                                    ),
                                                    margin: EdgeInsets.only(
                                                        bottom: 5.0),
                                                    width: (i == 7)
                                                        ? 200
                                                        : double.infinity,
                                                    height: 15.0,
                                                  ),
                                                ),
                                            ],
                                          )),
                                    ],
                                    if (snapshot.hasError ||
                                        snapshot.hasData) ...[
                                      Text(
                                        snapshot.hasError
                                            ? widget.article.subTitle
                                            : snapshot.data!.body.substring(
                                            snapshot.data!.body
                                                .indexOf("am ") +
                                                3,
                                            snapshot.data!.body
                                                .indexOf(", um")),
                                        style:
                                        Design.articleSubtitleTextStyle,
                                      ),
                                      Padding(
                                          padding: const EdgeInsets.only(
                                              top: 30.0),
                                          child: snapshot.hasError
                                              ? Text(
                                            'Ein Fehler beim Laden der aktuellen Wetterdaten vom deutschen Wetterdienst ist aufgetreten. Überprüfe die Internetverbindung.',
                                            style: Design
                                                .articleTextStyle,
                                          )
                                              : Html(
                                            data: snapshot.data!.body
                                                .substring(
                                                snapshot.data!
                                                    .body
                                                    .indexOf(
                                                    "Alpenraum</h4>") +
                                                    14,
                                                snapshot
                                                    .data!
                                                    .body
                                                    .length -
                                                    2)
                                                .replaceAll(
                                                '<p><span role=\\"text\\"></span></p>',
                                                ""),
                                            style: {
                                              "p": Style(
                                                fontSize:
                                                FontSize(15.0),
                                              ),
                                              "h4": Style(
                                                fontSize:
                                                FontSize(17.0),
                                              )
                                            },
                                          )),
                                      _UrlButton(url: widget.article.url, displayUrl: widget.article.displayUrl)
                                    ],
                                  ],
                                );
                              }),
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
                  opacity:
                  ref.watch(_closeButtonVisibilityProvider) ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 100),
                  child: CustomCloseButton(
                    onPressed: () {
                      ref
                          .read(_closeButtonVisibilityProvider.notifier)
                          .state =
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

class _UrlButton extends StatelessWidget {
  final String url;
  final String displayUrl;
  const _UrlButton({required this.url, required this.displayUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(top: 30, bottom: 30),
      child: TextButton(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                displayUrl,
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
              ),
              Padding(
                padding: EdgeInsets.only(left: 15.0),
                child: Icon(Icons.launch_rounded),
              )
            ],
          ),
          onPressed: () async {
            launchUrl(Uri.parse(url));
          }),
    );
  }
}
