import 'package:bergdinge/data/sports.dart';
import 'package:bergdinge/models/equipment.dart';
import 'package:bergdinge/models/packing_plan_item.dart';

import '../models/tip.dart';

class TipsData {
  TipsData._();

  static final List<Tip> tips = [
    Tip(
        imagePath: 'items/1.3.2.png',
        title: 'LVS Ausrüstung',
        subTitle:
            'Denke auf Skitour immer an deine LVS Ausrüstung: LVS-Gerät, Sonde und Schaufel.',
        relevantSports: ['Skitour', 'Freeride'],
        condition: (items, equipment) {
          return _checkCondition(items, equipment, '1.3.2') &&
              _checkCondition(items, equipment, '1.3.3') &&
              _checkCondition(items, equipment, '1.3.4');
        }),
    Tip(
      imagePath: 'items/1.3.1.png',
      title: 'Erste Hilfe',
      subTitle:
          'Du solltest auf jeder Tour ein kleines Erste Hilfe Set dabei haben.',
      relevantSports: Sports.sports,
      condition: (items, equipment) =>
          _checkCondition(items, equipment, '1.3.1'),
    ),
    Tip(
      imagePath: 'items/1.1.1.png',
      title: 'Klettergurt',
      subTitle: 'Packe einen Klettergurt ein.',
      relevantSports: Sports.sports
              .where((element) => element.toLowerCase().contains('kletter'))
              .toList() +
          ['Hochtour'],
      condition: (items, equipment) =>
          _checkCondition(items, equipment, '1.1.1'),
    ),
    Tip(
      imagePath: 'items/1.7.6.png',
      title: 'Hüttenschlafsack',
      subTitle: 'Ein Hüttenschlafsack ist auf den meisten Hütten Pflicht.',
      relevantSports: const ['Hüttentour'],
      condition: (items, equipment) =>
          _checkCondition(items, equipment, '1.7.6'),
    ),
    Tip(
      imagePath: 'items/1.1.0.png',
      title: 'Kletterhelm',
      subTitle:
          'Steinschlag kann jederzeit auftreten! Nimm einen Kletterhelm mit.',
      relevantSports: Sports.sports
              .where((element) => element.toLowerCase().contains('kletter'))
              .toList() +
          ['Hochtour'],
      condition: (items, equipment) =>
          _checkCondition(items, equipment, '1.1.0'),
    ),
    Tip(
      imagePath: 'items/3.0.png',
      title: 'Getränke',
      subTitle:
          'Hydration ist auf jeder Tour wichtig! Denke daran, etwas zu trinken einzupacken.',
      relevantSports: Sports.sports,
      condition: (items, equipment) => _checkCondition(items, equipment, '3.0'),
    ),
    Tip(
      imagePath: 'items/0.0.0.png',
      title: 'Brille',
      subTitle:
          'Eine Brille ist bei Schnee wichtig, um Schneeblindheit zu vermeiden.',
      relevantSports: const ['Hochtour', 'Ski', 'Skitour', 'Freeride'],
      condition: (items, equipment) =>
          _checkCondition(items, equipment, '0.0.0'),
    ),
    Tip(
      imagePath: 'items/1.6.1.png',
      title: 'Rucksack',
      subTitle:
          'Du brauchst einen Rucksack oder eine andere Tasche.',
      relevantSports: Sports.sports,
      condition: (items, equipment) =>
          _checkCondition(items, equipment, '1.6.0') ||
          _checkCondition(items, equipment, '1.6.1') ||
          _checkCondition(items, equipment, '1.6.2'),
    ),
  ];

  static bool _checkCondition(List<PackingPlanItem>? items,
      List<Equipment> equipment, String categoryId) {
    return items?.any((element1) =>
            equipment
                .singleWhere((element2) => element1.equipmentId == element2.id)
                .category ==
            categoryId) ??
        false;
  }
}
