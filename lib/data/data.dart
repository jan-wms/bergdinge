import 'package:equipment_app/data_models/category.dart';

enum EquipmentStatus {
  active,
  disabled;

  factory EquipmentStatus.fromString(
    String s,
    ) {
    switch (s) {
      case 'EquipmentStatus.disabled':
        return EquipmentStatus.disabled;
      case 'EquipmentStatus.active':
        return EquipmentStatus.active;
      default:
        return EquipmentStatus.active;
    }
  }
}

class Data {
  static List<String> sports = [
    'Wandern',
    'Klettern',
    'Hochtour',
    'Ski',
    'Skitour',
    'Sportklettern',
    'Mehrtagestour',
    'Tagestour',
    'Alpinklettern',
    'Tradklettern',
    'Freeride',
    'Klettersteig',
  ];

  static List<Category> categories = [
    Category(name: 'Bekleidung', id: 0, subCategories: [
      Category(name: 'Accessories', id: 1, subCategories: [
        Category(name: 'Brillen', id: 2, subCategories: [
          Category(name: 'Gletscherbrillen', id: 3),
          Category(name: 'Sicherungsbrillen',id: 4),
          Category(name: 'Skibrillen', id: 5),
          Category(name: 'Sonnenbrillen', id: 6),
          Category(name: 'Sonstige', id: 7),
        ]),
        Category(name: 'Gamaschen', id: 8),
        Category(name: 'Gürtel & Hosenträger', id: 9),
        Category(name: 'Handschuhe', id: 10),
        Category(name: 'Kopfbedeckungen', subCategories: [
          Category(name: 'Mützen', id: 12),
          Category(name: 'Stirnbänder', id: 13),
          Category(name: 'Sturmhauben', id: 14),
          Category(name: 'Hüte', id: 15),
          Category(name: 'Caps', id: 16),
          Category(name: 'Sonstige', id: 17),
        ], id: 11),
        Category(name: 'Multifunktionstücher & Schals', id: 18),
        Category(name: 'Sonstige', id: 19),
      ]),
      Category(name: 'Baselayer', subCategories: [
        Category(name: 'BHs', id: 21),
        Category(name: 'Hemden', id: 22),
        Category(name: 'Longsleeves', id: 23),
        Category(name: 'Tanktops', id: 24),
        Category(name: 'T-Shirts', id: 25),
        Category(name: 'Unterhemden', id: 26),
        Category(name: 'Unterhosen', id: 27),
        Category(name: 'Lange Unterhosen', id: 28),
        Category(name: 'Sonstige', id: 29),
      ], id: 20),
      Category(name: 'Hosen', subCategories: [
        Category(name: 'Hardshellhosen', id: 31),
        Category(name: 'Hochtourenhosen', id: 32),
        Category(name: 'Isolationshosen', id: 33),
        Category(name: 'Kletterhosen', id: 34),
        Category(name: 'Laufhosen', id: 35),
        Category(name: 'Shorts', id: 36),
        Category(name: 'Skihosen', id: 37),
        Category(name: 'Skitourenhosen', id: 38),
        Category(name: 'Softshellhosen', id: 39),
        Category(name: 'Trekkinghosen', id: 40),
        Category(name: 'Sonstige', id: 41),
      ], id: 30),
      Category(name: 'Jacken', subCategories: [
        Category(name: 'Hardshelljacken', id: 43),
        Category(name: 'Isolationsjacken', id: 44),
        Category(name: 'Ponchos', id: 45),
        Category(name: 'Skijacken', id: 46),
        Category(name: 'Softshelljacken', id: 47),
        Category(name: 'Windbreaker', id: 48),
        Category(name: 'Sonstige', id: 49),
      ], id: 42),
      Category(name: 'Second Layer', subCategories: [
        Category(name: 'Fleece', id: 51),
        Category(name: 'Hoodies & Pullover', id: 52),
        Category(name: 'Wolle & Merino', id: 53),
        Category(name: 'Sonstige', id: 54),
      ], id: 50),
      Category(name: 'Westen', id: 55),
      Category(name: 'Socken', subCategories: [
        Category(name: 'Laufsocken', id: 57),
        Category(name: 'Skisocken', id: 58),
        Category(name: 'Wandersocken', id: 59),
        Category(name: 'Sonstige', id: 60),
      ], id: 56),
    ]),
    Category(name: 'Schuhe', subCategories: [
      Category(name: 'Barfussschuhe', id: 62),
      Category(name: 'Berg- & Wanderschuhe', id: 63),
      Category(name: 'Hüttenschuhe', id: 64),
      Category(name: 'Kletterschuhe', id: 65),
      Category(name: 'Sandalen', id: 66),
      Category(name: 'Trail- & Laufschuhe', id: 67),
      Category(name: 'Winterschuhe', id: 68),
      Category(name: 'Zustiegsschuhe', id: 69),
      Category(name: 'Sonstige', id: 70),
    ], id: 61),
    Category(name: 'Ausrüstung', subCategories: [
      Category(name: 'Hygiene', subCategories: [
        Category(name: 'Drogerie & Körperpflege', id: 73),
        Category(name: 'Handtücher', id: 74),
        Category(name: 'Insekten- & Sonnenschutz', id: 75),
        Category(name: 'Wasseraufbereitung', id: 76),
        Category(name: 'Sonstige', id: 77),
      ], id: 72),
      Category(name: 'Klettern', subCategories: [
        Category(name: 'Kletterhelm', id: 79),
        Category(name: 'Klettergurt', id: 80),
        Category(name: 'Klettersteigset', id: 81),
        Category(name: 'Sicherungs- & Abseilgeräte', id: 82),
        Category(name: 'Hochtouren- & Eisausrüstung', subCategories: [
          Category(name: 'Steigeisen', id: 83),
          Category(name: 'Eispickel', id: 84),
          Category(name: 'Eisschrauben', id: 85),
        ], id: 83),
        Category(name: 'Kletter- & Boulderzubehör', subCategories: [
          Category(name: 'Chalkbags', id: 87),
          Category(name: 'Chalk', id: 88),
          Category(name: 'Kletter- & Boulderbürsten', id: 89),
          Category(name: 'Crashpads', id: 90),
        ], id: 86),
        Category(name: 'Karabiner & Expressen', subCategories: [
          Category(name: 'HMS-Karabiner', id: 92),
          Category(name: 'Schnappkarabiner', id: 93),
          Category(name: 'Express-Schlingen', id: 94),
          Category(name: 'Sonstige', id: 95),
        ], id: 91),
        Category(name: 'Seile, Schlingen & Reepschnüre', subCategories: [
          Category(name: 'Bandschlingen', id: 97),
          Category(name: 'Reepschnur', id: 98),
          Category(name: 'Kletterseile', id: 99),
          Category(name: 'Seilsäcke', id: 100),
        ], id: 96),
        Category(name: 'Klemmgeräte & Friends', id: 101),
        Category(name: 'Sonstige', id: 102),
      ], id: 78),
      Category(name: 'Messer & Werkzeuge', subCategories: [
        Category(name: 'Äxte & Beile', id: 104),
        Category(name: 'Feststehende Messer', id: 105),
        Category(name: 'Taschenmesser und Multitools', id: 106),
        Category(name: 'Sonstige', id: 107),
      ], id: 103),
      Category(name: 'Notfallausrüstung', subCategories: [
        Category(name: 'Erste Hilfe', id: 109),
        Category(name: 'Lawinenausrüstung', subCategories: [
          Category(name: 'LVS-Geräte', id: 111),
          Category(name: 'Schaufeln', id: 112),
          Category(name: 'Sonden', id: 113),
        ], id: 110),
        Category(name: 'Biwaksack', id: 114),
        Category(name: 'Sonstige', id: 115),
      ], id: 108),
      Category(name: 'Orientierung & Technik', subCategories: [
        Category(name: 'GPS-Geräte', id: 117),
        Category(name: 'Kompasse', id: 118),
        Category(name: 'Stirn & Taschenlampen', id: 119),
        Category(name: 'Batterien & Akkus', id: 120),
        Category(name: 'Kabel & Stecker', id: 121),
        Category(name: 'Kameras', id: 122),
        Category(name: 'Smartphone', id: 123),
        Category(name: 'Uhr', id: 124),
        Category(name: 'Bücher & Karten', subCategories: [
          Category(name: 'Kletterführer', id: 126),
          Category(name: 'Trainings- & Lehrbücher', id: 127),
          Category(name: 'Wanderführer', id: 128),
          Category(name: 'Kartenmaterial', id: 129),
        ], id: 125),
        Category(name: 'Sonstige', id: 130),
      ], id: 116),
      Category(name: 'Outdoor Küche', subCategories: [
        Category(name: 'Trinkflaschen & Wasserträger', subCategories: [
          Category(name: 'Trinkflaschen', id: 133),
          Category(name: 'Thermoskannen', id: 134),
          Category(name: 'Trinkblasen', id: 135),
        ], id: 132),
        Category(name: 'Kocher', id: 136),
        Category(name: 'Töpfe & Pfannen', id: 137),
        Category(name: 'Geschirr & Besteck', id: 138),
        Category(name: 'Behälter', id: 139),
        Category(name: 'Grill & Feuer', id: 140),
        Category(name: 'Sonstige', id: 141),
      ], id: 131),
      Category(name: 'Rucksäcke & Taschen', subCategories: [
        Category(name: 'Packsäcke', id: 143),
        Category(name: 'Rucksäcke', subCategories: [
          Category(name: 'Hochtouren- & Kletterrucksäcke', id: 145),
          Category(name: 'Kraxen', id: 147),
          Category(name: 'Ski- & Lawinenrucksäcke', id: 148),
          Category(name: 'Trailrunning Rucksäcke', id: 149),
          Category(name: 'Wander- & Trekkingrucksäcke', id: 150),
          Category(name: 'Sonstige', id: 151),
        ], id: 144),
        Category(name: 'Schutzhüllen', id: 152),
        Category(name: 'Taschen', id: 153),
        Category(name: 'Sonstige', id: 154),
      ], id: 142),
      Category(name: 'Schlafen & Liegen', subCategories: [
        Category(name: 'Biwaksäcke', id: 156),
        Category(name: 'Decken', id: 157),
        Category(name: 'Hängematte', id: 158),
        Category(name: 'Isomatte', id: 159),
        Category(name: 'Kissen', id: 160),
        Category(name: 'Moskitonetze', id: 161),
        Category(name: 'Schlafsack', id: 162),
        Category(name: 'Tarps', id: 162),
        Category(name: 'Zelte', id: 163),
        Category(name: 'Sonstige', id: 164),
      ], id: 155),
      Category(name: 'Stöcke', subCategories: [
        Category(name: 'Ski Stöcke', id: 166),
        Category(name: 'Trekkingstöcke', id: 167),
        Category(name: 'Trailrunning Stöcke', id: 168),
        Category(name: 'Sonstige', id: 169),
      ], id: 165),
      Category(name: 'Wintersportausrüstung', subCategories: [
        Category(name: 'Grödel & Spikes', id: 171),
        Category(name: 'Rodel', id: 172),
        Category(name: 'Schneeschuhe', id: 173),
        Category(name: 'Ski', subCategories: [
          Category(name: 'Bindungen', id: 175),
          Category(name: 'Harscheisen', id: 176),
          Category(name: 'Ski', id: 177),
          Category(name: 'Skifelle', id: 178),
          Category(name: 'Skihelme & Protektoren', id: 179),
          Category(name: 'Skischuhe', id: 180),
        ], id: 174),
        Category(name: 'Sonstige', id: 181),
      ], id: 170),
    ], id: 71),
    Category(name: 'Verpflegung', subCategories: [Category(name: 'Getränke', id: 183), Category(name: 'Nahrung', id: 184),], id: 182,),
  ];
}
