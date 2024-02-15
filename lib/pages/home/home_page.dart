import 'dart:ui';

import 'package:equipment_app/custom_widgets/custom_appbar.dart';
import 'package:equipment_app/data_models/article.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/design.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final articles = <Article>[
    Article(title: 'Rucksack richtig packen', subTitle: 'Ratgeber', imageProvider: const AssetImage('assets/items/backpack.jpg')),
    Article(title: 'Alpenacademy', subTitle: 'Ratgeber', imageProvider: const AssetImage('assets/items/landscape.jpg')),
    Article(title: 'Ausrüstungsverleih', subTitle: 'Ratgeber', imageProvider: const AssetImage('assets/items/landscape2.jpg')),
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        const CustomAppBar(
          title: 'Entdecken',
          icon: Icons.terrain,
          subtitle: 'Bergdinge',
        ),
        SliverPadding(
          padding: Design.pagePadding.copyWith(top: 30.0, bottom: 30.0),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 13/9,
                crossAxisSpacing: 15.0,
                mainAxisSpacing: 15.0,
                crossAxisCount: 2,
            ),
            delegate: SliverChildListDelegate(
              [
                for (var a in articles)
                  _ArticleCard(article: a,)
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final Article article;

  const _ArticleCard(
      {required this.article});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.push('/article', extra: article),
        child: Hero(
          tag: article.title.toString(),
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.red,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 4,
                    blurRadius: 10,
                    offset: const Offset(2, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    child: Stack(alignment: Alignment.bottomLeft, children: [
                      Image(image: article.imageProvider,),
                      ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                        child: ShaderMask(
                          shaderCallback: (rect) {
                            return LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black,
                                  Colors.black.withOpacity(0)
                                ],
                                stops: const [
                                  0.7,
                                  0.6
                                ]).createShader(rect);
                          },
                          blendMode: BlendMode.dstOut,
                          child: Image(image: article.imageProvider,),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0, left: 10.0),
                        child: Text(
                          article.title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.w500),
                        ),
                      )
                    ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
