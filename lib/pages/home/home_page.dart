import 'package:bergdinge/custom_widgets/custom_appbar.dart';
import 'package:bergdinge/data_models/article.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
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
      subTitle: 'Tipps',
      imageProvider: const AssetImage('assets/articles/backpack.jpg'),
      color: const Color.fromRGBO(35, 63, 33, 1.0),
      content: [
        const Text(
          'Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergrenluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo  et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor ins et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.',
          style: Design.articleTextStyle,
        )
      ],
    ),
    Article(
      title: 'Alpenacademy',
      subTitle: 'Youtube',
      imageProvider: const AssetImage('assets/articles/alpaca.jpg'),
      color: const Color.fromRGBO(50, 71, 94, 1.0),
      content: [
        const Text(
          'Bei der AlpenAcademy lernst du alles rund ums Thema Bergsport. Meine Kurse sollen dir alles vermitteln, was man so braucht, um sicher, erfolgreich und bequem den schönsten Sport der Welt genießen zu können. Im Detail geht es um die Themen Klettern, Bergsteigen, Skitouren, Technik, Tourenguides und Ausrüstung! Du wirst auf meinem Kanal bestimmt fündig.',
          style: Design.articleTextStyle,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 30.0,bottom: 30.0),
          child: TextButton(
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('youtube.com/@alpenacademy',style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600
                  ),),
                  Padding(
                    padding: EdgeInsets.only(left: 15.0),
                    child: Icon(Icons.launch_rounded),
                  )
                ],
              ),
              onPressed: () async {
                final Uri url = Uri.parse('https://www.youtube.com/@alpenacademy/');
                launchUrl(url);
              }),
        ),
      ],
    ),
    Article(
      title: 'Rucksack richtig einstellen',
      subTitle: 'Ratgeber',
      color: const Color.fromRGBO(91, 94, 91, 1.0),
      imageProvider: const AssetImage('assets/articles/landscape2.jpg'),
      content: [
        const Text(
          'Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergrenluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo  et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor ins et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.',
          style: Design.articleTextStyle,
        )
      ],
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
            sliver: SliverToBoxAdapter(
              child: Align(
                alignment: Alignment.center,
                child: Wrap(
                  spacing: 25.0,
                  runSpacing: 25.0,
                  direction: Axis.horizontal,
                  children: [
                    for (var a in articles)
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
                            color: Colors.grey.withOpacity(0.2),
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
                            color: Colors.white.withOpacity(0.9), fontSize: 16),
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

