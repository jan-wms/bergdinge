/*https://stackoverflow.com/questions/63596715/flutter-custom-sliver-app-bar-with-search-bar*/
import 'dart:ui';
import 'dart:math';
import 'package:equipment_app/data/design.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onButtonPressed;
  final ValueSetter<String>? onSearchChanged;
  final IconData? buttonIcon;
  final String searchInitialValue;

  const CustomAppBar(
      {super.key,
      required this.title,
      this.onButtonPressed,
      this.icon,
      this.onSearchChanged,
      this.subtitle,
        this.searchInitialValue = '',
      this.buttonIcon})
      : assert(
          (onSearchChanged == null || subtitle == null),
          'Only one parameters is allowed.',
        );

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      floating: false,
      delegate: SearchHeader(
        subtitle: subtitle,
        onButtonPressed: onButtonPressed,
        buttonIcon: buttonIcon ?? Icons.add_rounded,
        icon: icon,
        title: title,
        search: (onSearchChanged != null)
            ? Search(
          initialValue: searchInitialValue,
            onChanged: (value) => onSearchChanged!(value))
            : null,
      ),
    );
  }
}

class Search extends StatefulWidget {
  final ValueSetter<String> onChanged;
  final String initialValue;

  const Search({super.key, required this.onChanged, required this.initialValue});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  late TextEditingController _editingController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _editingController = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    super.dispose();
    _focusNode.dispose();
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
              focusNode: _focusNode,
              controller: _editingController,
              onChanged: (value) {
                widget.onChanged(value);
                setState(() {});
              },
              decoration: InputDecoration(
                hintText: 'Suchen',
                hintStyle: TextStyle(
                    color: Theme.of(context).primaryColor.withOpacity(0.7)),
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
          _editingController.text.trim().isEmpty
              ? IconButton(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  icon: Icon(Icons.search,
                      color: Theme.of(context).primaryColor.withOpacity(0.7)),
                  onPressed: () => _focusNode.requestFocus(),
                )
              : IconButton(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  icon: Icon(Icons.clear,
                      color: Theme.of(context).primaryColor.withOpacity(0.7)),
                  onPressed: () => setState(
                    () {
                      _editingController.clear();
                      widget.onChanged('');
                    },
                  ),
                ),
        ],
      ),
    );
  }
}

class SearchHeader extends SliverPersistentHeaderDelegate {
  final VoidCallback? onButtonPressed;
  final String title;
  final IconData? icon;
  final Widget? search;
  final String? subtitle;
  final IconData buttonIcon;

  SearchHeader({
    required this.buttonIcon,
    required this.onButtonPressed,
    required this.title,
    this.icon,
    this.search,
    this.subtitle,
  }) : assert(
          (search == null || subtitle == null),
          'Only one parameters is allowed.',
        );

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final double minTopBarHeight =
        80 + MediaQueryData.fromView(View.of(context)).padding.top;
    final double maxTopBarHeight =
        180 + MediaQueryData.fromView(View.of(context)).padding.top;
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
              //TODO
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),

              //topRight: Radius.circular(20),
             // topLeft: Radius.circular(20),

            )),
        child: Padding(
          padding: EdgeInsets.only(top: MediaQueryData.fromView(View.of(context)).padding.top),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(
                width: 20,
              ),
              if (icon != null)
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
              child: Wrap(
                spacing: 15.0,
                direction: Axis.horizontal,
                children: [
                  if (search != null || subtitle != null)
                    Container(
                      alignment: Alignment.center,
                      width: 200,
                      height: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              offset: const Offset(0, 7),
                              blurRadius: 10,
                              color: Design.colors[1].withOpacity(0.23),
                            )
                          ]),
                      child: search ??
                          Text(
                            subtitle!,
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.7)),
                          ),
                    ),
                  if (onButtonPressed != null)
                    Container(
                      alignment: Alignment.center,
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              offset: const Offset(0, 7),
                              blurRadius: 10,
                              color: Design.colors[1].withOpacity(0.23),
                            )
                          ]),
                      child: IconButton(
                        onPressed: onButtonPressed,
                        highlightColor: Colors.transparent,
                        icon: Icon(buttonIcon,
                            color: Theme.of(context)
                                .primaryColor
                                .withOpacity(0.7)),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (shrinkFactor > 0.5) topBar,
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;

  @override
  double get maxExtent => 210 + MediaQueryData.fromView(PlatformDispatcher.instance.views.first).padding.top;

  @override
  double get minExtent => 80 + MediaQueryData.fromView(PlatformDispatcher.instance.views.first).padding.top;

}
