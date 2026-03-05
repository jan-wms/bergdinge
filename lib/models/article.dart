import 'package:flutter/material.dart';

class Article {
  final String title;
  final String subTitle;
  final ImageProvider<Object> imageProvider;
  final List<Widget>? content;
  final String url;
  final String displayUrl;
  final Color color;
  final bool isWeather;

  Article(
      {required this.title,
      required this.subTitle,
      required this.imageProvider,
      this.content,
      required this.color,
      this.isWeather = false,
      required this.url,
      required this.displayUrl}) {
    assert((content != null && !isWeather) || (content == null && isWeather),
        'You must provide either content or isWeather = true, but not both.');
  }
}
