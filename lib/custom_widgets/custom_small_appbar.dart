/*https://stackoverflow.com/questions/63596715/flutter-custom-sliver-app-bar-with-search-bar*/
import 'dart:io';
import 'dart:ui';
import 'package:equipment_app/data/design.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomSmallAppBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool disableRoundedCorners;
  final List<Widget>? actions;

  const CustomSmallAppBar({
    super.key,
    required this.title,
    this.actions,
    this.subtitle,
    this.disableRoundedCorners = false,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      floating: false,
      delegate: _SmallHeader(
        disableRoundedCorners: disableRoundedCorners,
        title: title,
        actions: actions,
      ),
    );
  }
}

class _SmallHeader extends SliverPersistentHeaderDelegate {
  final String title;
  final bool disableRoundedCorners;
  final List<Widget>? actions;

  _SmallHeader({
    this.actions,
    required this.title,
    required this.disableRoundedCorners,
  });

  bool get isIOS {
    if (kIsWeb) {
      return false;
    }
    if (Platform.isIOS || Platform.isMacOS) {
      return true;
    }
    return false;
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final double minTopBarHeight =
        80 + MediaQueryData.fromView(View.of(context)).padding.top;

    return SizedBox(
      height: minExtent,
      child: Container(
        //alignment: Alignment.center,
        height: minTopBarHeight,
        //width: 100,
        decoration: BoxDecoration(
            color: Design.colors[1],
            borderRadius: BorderRadius.all(
              (MediaQuery.of(context).size.width > Design.breakpoint1 &&
                      MediaQuery.of(context).orientation ==
                          Orientation.landscape &&
                      !disableRoundedCorners)
                  ? const Radius.circular(20)
                  : Radius.zero,
            )),
        child: Padding(
          padding: EdgeInsets.only(
              top: MediaQueryData.fromView(View.of(context)).padding.top),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 0.0,
                child: IconButton(
                  color: Colors.white,
                  onPressed: () => context.pop(),
                  icon: Icon(isIOS
                      ? Icons.arrow_back_ios_new_rounded
                      : Icons.arrow_back_rounded),
                ),
              ),
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width - 90,
                ),
                child: Text(title,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              Positioned(
                  right: 0.0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: actions ?? [],
                  )),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;

  @override
  double get minExtent =>
      80 +
      MediaQueryData.fromView(PlatformDispatcher.instance.views.first)
          .padding
          .top;

  @override
  double get maxExtent => minExtent;
}
