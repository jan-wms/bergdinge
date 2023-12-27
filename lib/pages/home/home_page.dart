import 'dart:ui';

import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: <Widget>[
          const SliverAppBar(
            expandedHeight: 100,
            collapsedHeight: 40,
            toolbarHeight: 0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.only(left: 20),
              centerTitle: false,
              title: Text(
                'Entdecken',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            sliver: SliverList.builder(
              itemCount: images.length,
              itemBuilder: (context, index) {
                String image = images[index];
                return Container(
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
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      child: Stack(alignment: Alignment.bottomLeft, children: [
                        Image.asset(image),
                        ImageFiltered(
                          imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
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
                        const Padding(
                          padding: EdgeInsets.only(bottom: 20.0, left: 10.0),
                          child: Text(
                            'How to: Rucksack packen',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.w500),
                          ),
                        )
                      ])),
                );
              },
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(top: 30.0)),
        ],
      ),
    );
  }
}
