import 'package:flutter/material.dart';

class Article {
  final String title;
  final String subTitle;
  final ImageProvider<Object> imageProvider;
  final List<Widget> content;
  final Color color;
  Article({required this.title, required this.subTitle, required this.imageProvider, required this.content, required this.color});

}