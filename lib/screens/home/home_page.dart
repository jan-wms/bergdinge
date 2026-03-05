import 'package:bergdinge/data/article_data.dart';
import 'package:bergdinge/models/article.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/design.dart';
import '../../widgets/custom_sliver_app_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        const CustomSliverAppBar(
          title: 'Entdecken',
          icon: Icons.terrain,
          subtitle: 'Bergdinge',
        ),
        SliverPadding(
            padding: Design.pagePadding.copyWith(top: 30.0, bottom: 30.0),
            sliver: SliverToBoxAdapter(
              child: Align(
                alignment: Alignment.center,
                child: Wrap(
                  spacing: 25.0,
                  runSpacing: 25.0,
                  direction: Axis.horizontal,
                  children: [
                    for (var a in ArticleData.articles)
                      _ArticleCard(
                        article: a,
                      ),
                  ],
                ),
              ),
            )),
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
              constraints: const BoxConstraints(
                maxWidth: 400.0,
              ),
              child: AspectRatio(
                aspectRatio: 5 / 4,
                child: Stack(
                  children: [
                    Container(
                      alignment: Alignment.bottomCenter,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: article.imageProvider, fit: BoxFit.cover),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: article.color,
                            style: BorderStyle.solid,
                            width: 4.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.2),
                            spreadRadius: 4,
                            blurRadius: 10,
                            offset: const Offset(2, 3),
                          ),
                        ],
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: article.color,
                          borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(16.0)),
                        ),
                        child: Text(
                          article.title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 20.0),
                      decoration: BoxDecoration(
                        color: article.color,
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16.0),
                            bottomRight: Radius.circular(16.0)),
                      ),
                      child: Text(
                        article.subTitle,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
