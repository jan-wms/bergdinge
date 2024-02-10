/*https://stackoverflow.com/questions/63596715/flutter-custom-sliver-app-bar-with-search-bar*/
import 'dart:ui';
import 'dart:math';
import 'package:equipment_app/data/design.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  final IconData? icon;
  final VoidCallback? onAddButtonPressed;
  const CustomAppBar({super.key, required this.title, this.onAddButtonPressed, this.icon});

  @override
  Widget build(BuildContext context) {
    return  SliverPersistentHeader(
      pinned: true,
      floating: false,
      delegate: SearchHeader(
        icon: icon ?? Icons.terrain,
        title: title,
        search: const _Search(

        ),
      ),
    );
  }
}

class _Search extends StatefulWidget {
  const _Search();

  @override
  __SearchState createState() => __SearchState();
}

class __SearchState extends State<_Search> {
  late TextEditingController _editingController;

  @override
  void initState() {
    super.initState();
    _editingController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              controller: _editingController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Suchen',
                hintStyle: TextStyle(
                    color: Theme.of(context).primaryColor.withOpacity(0.5)),
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
          _editingController.text.trim().isEmpty
              ? IconButton(
              icon: Icon(Icons.search,
                  color: Theme.of(context).primaryColor.withOpacity(0.5)),
              onPressed: null)
              : IconButton(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            icon: Icon(Icons.clear,
                color: Theme.of(context).primaryColor.withOpacity(0.5)),
            onPressed: () => setState(
                  () {
                _editingController.clear();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SearchHeader extends SliverPersistentHeaderDelegate {
  final double minTopBarHeight = 80 + MediaQueryData.fromView(window).padding.top;
  final double maxTopBarHeight = 180 + MediaQueryData.fromView(window).padding.top;
  final String title;
  final IconData icon;
  final Widget search;

  SearchHeader({
    required this.title,
    required this.icon,
    required this.search,
  });

  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent,
      ) {
    var shrinkFactor = min(1, shrinkOffset / (maxExtent - minExtent));

    var topBar = Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        alignment: Alignment.center,
        height:
        max(maxTopBarHeight * (1 - shrinkFactor * 1.45), minTopBarHeight),
        width: 100,
        decoration: BoxDecoration(
            color: Design.colors[1],
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(36),
              bottomRight: Radius.circular(36),
            )),
        child: Padding(
          padding: EdgeInsets.only(top: MediaQueryData.fromView(window).padding.top),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(
                width: 20,
              ),
              Icon(
                icon,
                size: 40,
                color: Colors.white,
              )
            ],
          ),
        ),
      ),
    );
    return SizedBox(
      height: max(maxExtent - shrinkOffset, minExtent),
      child: Stack(
        fit: StackFit.loose,
        children: [
          if (shrinkFactor <= 0.5) topBar,
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 10,
              ),
              child: Container(
                alignment: Alignment.center,
                width: 200,
                height: 50,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0, 5),
                        blurRadius: 10,
                        color: Design.colors[1].withOpacity(0.23),
                      )
                    ]),
                child: search,
              ),
            ),
          ),
          if (shrinkFactor > 0.5) topBar,
        ],
      ),
    );
  }

  @override
  double get maxExtent => 210 + MediaQueryData.fromView(window).padding.top;

  @override
  double get minExtent => 80 + MediaQueryData.fromView(window).padding.top;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
