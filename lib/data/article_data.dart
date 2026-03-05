import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/article.dart';
import 'design.dart';

class ArticleData {
  static List<Article> get articles => <Article>[
    Article(
      title: 'Rucksack richtig packen',
      subTitle: 'Tipps',
      url: 'https://www.deuter.com/de-de/beratung/rucksack-richtig-packen',
      displayUrl: 'deuter.com/',
      imageProvider: const AssetImage('assets/articles/backpack.jpg'),
      color: const Color.fromRGBO(35, 63, 33, 1.0),
      content: const [
        Padding(
          padding: EdgeInsets.only(bottom: 20.0),
          child: Text(
            '"Das Wichtigste beim Rucksack packen ist, dass man alles Überflüssige gar nicht erst mitnimmt!"',
            style: Design.articleTextStyle,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gewichtsverteilung',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
              ),
              Text(
                  'Der Schwerpunkt des Rucksacks sollte nah am Körper und idealerweise in Schulterhöhe liegen, um eine stabile Balance und ein angenehmes Tragen zu gewährleisten.',
                  style: Design.articleTextStyle),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Packordnung',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
              ),
              Text(
                  'Bodenfach: Leichte Gegenstände wie Schlafsack und Daunenausrüstung.\nOberer Bereich: Mittelschwere Dinge wie Kleidung.\nNah am Rücken und in Schulterhöhe: Schwere Ausrüstung wie Zelt, Proviant und dicke Jacken.\nDeckelfach: Kleine Dinge, die schnell zugänglich sein müssen.',
                  style: Design.articleTextStyle),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vermeidung von äußeren Anbringungen',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
              ),
              Text(
                'Um das Hängenbleiben und Witterungseinflüsse zu minimieren, sollten möglichst wenig Ausrüstung außen am Rucksack befestigt werden.',
                style: Design.articleTextStyle,
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gleichmäßige Gewichtsverteilung',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
              ),
              Text(
                'Achte darauf, dass das Gewicht in Seitentaschen gleichmäßig verteilt ist. Verwende wasserdichte Packsäcke, um Ordnung und Schutz vor Regen zu gewährleisten.',
                style: Design.articleTextStyle,
              ),
            ],
          ),
        )
      ],
    ),
    Article(
        title: 'Wetterbericht Alpenraum',
        subTitle: 'Wetter',
        url: 'https://dwd.de/',
        displayUrl: 'dwd.de/',
        color: const Color.fromRGBO(50, 71, 94, 1.0),
        imageProvider: const AssetImage('assets/articles/weather.jpeg'),
        isWeather: true),
    Article(
      title: 'Watzmann Überschreitung',
      subTitle: 'Touren',
      //color: const Color.fromRGBO(182, 69, 30, 1.0),
      color: const Color.fromRGBO(35, 63, 33, 1.0),
      imageProvider: const AssetImage('assets/articles/watzmann.jpeg'),
      url: 'https://www.berchtesgaden.de/touren/watzmann-ueberschreitung',
      displayUrl: 'berchtesgaden.de/',
      content: [
        const Text(
          'Die wohl schönste Gratwanderung in den Alpen: Die legendäre Watzmann Überschreitung! Die anspruchsvolle Überschreitung der drei Haupt-Gipfel des Watzmanns wird im Allgemeinen als die Königstour der Berchtesgadener Alpen bezeichnet.',
          style: Design.articleTextStyle,
        ),
        Container(
          margin: EdgeInsets.only(top: 40),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: Icon(
                  Icons.upgrade_rounded,
                  color: Colors.black,
                ),
              ),
              Text('2022 hm',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold))
            ],
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Icon(
                CupertinoIcons.arrow_left_right,
                color: Colors.black,
              ),
            ),
            Text('23,3 km',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold))
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Icon(
                Icons.access_time_rounded,
                color: Colors.black,
              ),
            ),
            Text(
              '14:00 h',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ],
    ),
  ];
}