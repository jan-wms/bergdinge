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
    Article(
        title: 'Rucksack richtig packen',
        subTitle: 'Ratgeber',
        imageProvider: const AssetImage('assets/items/backpack.jpg'),
    ),
    Article(
        title: 'Alpenacademy',
        subTitle: 'Ratgeber',
        imageProvider: const AssetImage('assets/items/landscape.jpg'),
    ),
    Article(
        title: 'Ausrüstungsverleih',
        subTitle: 'Ratgeber',
        imageProvider: const AssetImage('assets/items/landscape2.jpg'),
    ),
    Article(
        title: 'Ausrüstungsverleih1',
        subTitle: 'Ratgeber',
        imageProvider: const AssetImage('assets/items/landscape2.jpg'),
    ),
    Article(
        title: 'Ausrüstungsverleih2',
        subTitle: 'Ratgeber',
        imageProvider: const AssetImage('assets/items/landscape.jpg'),
    ),
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
              childAspectRatio: 13 / 9,
              crossAxisSpacing: 30.0,
              mainAxisSpacing: 30.0,
              crossAxisCount: 2,
            ),
            delegate: SliverChildListDelegate(
              [
                for (var a in articles)
                  _ArticleCard(
                    article: a,
                  )
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

  const _ArticleCard({required this.article});

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
              alignment: Alignment.bottomLeft,
              decoration: BoxDecoration(
                image: DecorationImage(image: article.imageProvider, fit: BoxFit.cover),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 4,
                    blurRadius: 10,
                    offset: const Offset(2, 3),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(10.0),
                margin: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(10.0)
                ),
                child: Text(article.title, style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w600),),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
