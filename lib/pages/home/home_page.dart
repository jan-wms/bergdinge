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
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
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
                      children: [Image.asset('assets/items/landscape.jpg')],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    child: Stack(
                      children: [Image.asset('assets/items/backpack.jpg')],
                    ),
                  ),
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
