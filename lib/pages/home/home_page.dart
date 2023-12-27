import 'dart:ui';

import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    child: Stack(
                      alignment: Alignment.bottomLeft,
                      children: [
                        Image.asset('assets/items/landscape.jpg'),
                        ImageFiltered(
                          imageFilter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
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
                            child: Image.asset('assets/items/landscape.jpg'),
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
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    child: Stack(
                      alignment: Alignment.bottomLeft,
                      children: [
                        Image.asset('assets/items/backpack.jpg'),
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
                            child: Image.asset('assets/items/backpack.jpg'),
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
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      child: Stack(alignment: Alignment.bottomLeft, children: [
                        Image.asset('assets/items/landscape2.jpg'),
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
                            child: Image.asset('assets/items/landscape2.jpg'),
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
                ),
              ]),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 900, child: Placeholder()),
          ),
        ],
      ),
    );
  }
}
