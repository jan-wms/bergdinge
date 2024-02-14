import 'dart:ui';

import 'package:equipment_app/custom_widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/design.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final images = <String>[
    'assets/items/landscape.jpg',
    'assets/items/backpack.jpg',
    'assets/items/landscape2.jpg',
  ];

  final headlines = <String>[
    'Rucksack richtig packen',
    'Alpenacademy',
    'Ausrüstungsverleih',
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        //TODO
        padding: const EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0),
        child: CustomScrollView(
          slivers: <Widget>[
            const CustomAppBar(
              title: 'Entdecken',
              icon: Icons.terrain,
              subtitle: 'Bergdinge',
            ),
            SliverPadding(
              padding: Design.pagePadding,
              sliver: SliverList.builder(
                itemCount: images.length,
                itemBuilder: (context, index) {
                  String image = images[index];
                  return GestureDetector(
                    onTap: () => context.push('/article', extra: index),
                    child: Hero(
                      tag: index.toString(),
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          decoration: BoxDecoration(
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
                          margin: const EdgeInsets.only(top: 10, bottom: 10),
                          child: ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(20)),
                              child: Stack(
                                  alignment: Alignment.bottomLeft,
                                  children: [
                                    Image.asset(image),
                                    ImageFiltered(
                                      imageFilter:
                                          ImageFilter.blur(sigmaX: 7, sigmaY: 7),
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
                                        child: Image.asset(image),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 20.0, left: 10.0),
                                      child: Text(
                                        headlines[index],
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 25,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    )
                                  ])),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(top: 30.0)),
          ],
        ),
      ),
    );
  }
}
