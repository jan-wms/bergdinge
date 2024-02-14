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
  static String websiteUrl = 'https://bergdinge.de/';
  static String websiteUrlShort = 'bergdinge.de';
  static String supportMail = 'app@bergdinge.de';
  
  
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
    'Sonstige',
  ];

  static List<Category> categories = [
    Category(name: 'Bekleidung', id: '0', subCategories: [
      Category(name: 'Accessories', id: '0.0', subCategories: [
        Category(name: 'Brillen', id: '0.0.0', subCategories: [
          Category(name: 'Gletscherbrillen', id: '0.0.0.0'),
          Category(name: 'Sicherungsbrillen', id: '0.0.0.1'),
          Category(name: 'Skibrillen', id: '0.0.0.2'),
          Category(name: 'Sonnenbrillen', id: '0.0.0.3'),
          Category(name: 'Sonstige', id: '0.0.0.4'),
        ]),
        Category(name: 'Gamaschen', id: '0.0.1'),
        Category(name: 'Gürtel & Hosenträger', id: '0.0.2'),
        Category(name: 'Handschuhe', id: '0.0.3'),
        Category(
            name: 'Kopfbedeckungen',
            id: '0.0.4',
            subCategories: [
              Category(name: 'Mützen', id: '0.0.4.0'),
              Category(name: 'Stirnbänder', id: '0.0.4.1'),
              Category(name: 'Sturmhauben', id: '0.0.4.2'),
              Category(name: 'Hüte', id: '0.0.4.3'),
              Category(name: 'Caps', id: '0.0.4.4'),
              Category(name: 'Sonstige', id: '0.0.4.5'),
            ],
        ),
        Category(name: 'Multifunktionstücher & Schals', id: '0.0.5'),
        Category(name: 'Sonstige', id: '0.0.6'),
      ]),
      Category(
          name: 'Baselayer',
          id: '0.1',
          subCategories: [
            Category(name: 'BHs', id: '0.1.0'),
            Category(name: 'Hemden', id: '0.1.1'),
            Category(name: 'Longsleeves', id: '0.1.2'),
            Category(name: 'Tanktops', id: '0.1.3'),
            Category(name: 'T-Shirts', id: '0.1.4'),
            Category(name: 'Unterhemden', id: '0.1.5'),
            Category(name: 'Unterhosen', id: '0.1.6'),
            Category(name: 'Lange Unterhosen', id: '0.1.7'),
            Category(name: 'Sonstige', id: '0.1.8'),
          ],
      ),
      Category(
          name: 'Hosen',
          id: '0.2',
          subCategories: [
            Category(name: 'Hardshellhosen', id: '0.2.0'),
            Category(name: 'Hochtourenhosen', id: '0.2.1'),
            Category(name: 'Isolationshosen', id: '0.2.2'),
            Category(name: 'Kletterhosen', id: '0.2.3'),
            Category(name: 'Laufhosen', id: '0.2.4'),
            Category(name: 'Shorts', id: '0.2.5'),
            Category(name: 'Skihosen', id: '0.2.6'),
            Category(name: 'Skitourenhosen', id: '0.2.7'),
            Category(name: 'Softshellhosen', id: '0.2.8'),
            Category(name: 'Trekkinghosen', id: '0.2.9'),
            Category(name: 'Sonstige', id: '0.2.10'),
          ],
      ),
      Category(
          name: 'Jacken',
          id: '0.3',
          subCategories: [
            Category(name: 'Hardshelljacken', id: '0.3.0'),
            Category(name: 'Isolationsjacken', id: '0.3.1'),
            Category(name: 'Ponchos', id: '0.3.2'),
            Category(name: 'Skijacken', id: '0.3.3'),
            Category(name: 'Softshelljacken', id: '0.3.4'),
            Category(name: 'Windbreaker', id: '0.3.5'),
            Category(name: 'Sonstige', id: '0.3.6'),
          ],
          ),
      Category(
          name: 'Second Layer',
          id: '0.4',
          subCategories: [
            Category(name: 'Fleece', id: '0.4.0'),
            Category(name: 'Hoodies & Pullover', id: '0.4.1'),
            Category(name: 'Wolle & Merino', id: '0.4.2'),
            Category(name: 'Sonstige', id: '0.4.3'),
          ],
          ),
      Category(name: 'Westen', id: '0.5'),
      Category(
          name: 'Socken',
          id: '0.6',
          subCategories: [
            Category(name: 'Laufsocken', id: '0.6.0'),
            Category(name: 'Skisocken', id: '0.6.1'),
            Category(name: 'Wandersocken', id: '0.6.2'),
            Category(name: 'Sonstige', id: '0.6.3'),
          ],
          ),
    ]),
    Category(
        name: 'Ausrüstung',
        id: '1',
        subCategories: [
          Category(
              name: 'Hygiene',
              id: '1.0',
              subCategories: [
                Category(name: 'Drogerie & Körperpflege', id: '1.0.0'),
                Category(name: 'Handtücher', id: '1.0.1'),
                Category(name: 'Insekten- & Sonnenschutz', id: '1.0.2'),
                Category(name: 'Wasseraufbereitung', id: '1.0.3'),
                Category(name: 'Sonstige', id: '1.0.4'),
              ],),
          Category(
              name: 'Klettern',
              id: '1.1',
              subCategories: [
                Category(name: 'Kletterhelm', id: '1.1.0'),
                Category(name: 'Klettergurt', id: '1.1.1'),
                Category(name: 'Klettersteigset', id: '1.1.2'),
                Category(name: 'Sicherungs- & Abseilgeräte', id: '1.1.3'),
                Category(
                    name: 'Hochtouren- & Eisausrüstung',
                    id: '1.1.4',
                    subCategories: [
                      Category(name: 'Steigeisen', id: '1.1.4.0'),
                      Category(name: 'Eispickel', id: '1.1.4.1'),
                      Category(name: 'Eisschrauben', id: '1.1.4.2'),
                    ],
                    ),
                Category(
                    name: 'Kletter- & Boulderzubehör',
                    id: '1.1.5',
                    subCategories: [
                      Category(name: 'Chalkbags', id: '1.1.5.0'),
                      Category(name: 'Chalk', id: '1.1.5.1'),
                      Category(name: 'Kletter- & Boulderbürsten', id: '1.1.5.2'),
                      Category(name: 'Crashpads', id: '1.1.5.3'),
                    ],
                    ),
                Category(
                    name: 'Karabiner & Expressen',
                    id: '1.1.6',
                    subCategories: [
                      Category(name: 'Verschlusskarabiner', id: '1.1.6.0'),
                      Category(name: 'Schnappkarabiner', id: '1.1.6.1'),
                      Category(name: 'Express-Schlingen', id: '1.1.6.2'),
                      Category(name: 'Sonstige', id: '1.1.6.3'),
                    ],
                    ),
                Category(
                    name: 'Seile, Schlingen & Reepschnüre',
                    id: '1.1.7',
                    subCategories: [
                      Category(name: 'Bandschlingen', id: '1.1.7.0'),
                      Category(name: 'Reepschnur', id: '1.1.7.1'),
                      Category(name: 'Kletterseile', id: '1.1.7.2'),
                      Category(name: 'Seilsäcke', id: '1.1.7.3'),
                    ],
                    ),
                Category(name: 'Klemmgeräte & Friends', id: '1.1.8'),
                Category(name: 'Sonstige', id: '1.1.9'),
              ],
          ),
          Category(
              name: 'Messer & Werkzeuge',
              id: '1.2',
              subCategories: [
                Category(name: 'Äxte & Beile', id: '1.2.0'),
                Category(name: 'Feststehende Messer', id: '1.2.1'),
                Category(name: 'Taschenmesser und Multitools', id: '1.2.2'),
                Category(name: 'Sonstige', id: '1.2.3'),
              ],
          ),
          Category(
              name: 'Notfallausrüstung',
              id: '1.3',
              subCategories: [
                Category(name: 'Erste Hilfe', id: '1.3.0'),
                Category(
                    name: 'Lawinenausrüstung',
                    id: '1.3.1',
                    subCategories: [
                      Category(name: 'LVS-Geräte', id: '1.3.1.0'),
                      Category(name: 'Schaufeln', id: '1.3.1.1'),
                      Category(name: 'Sonden', id: '1.3.1.2'),
                    ],
                    ),
                Category(name: 'Biwaksack', id: '1.3.2'),
                Category(name: 'Sonstige', id: '1.3.3'),
              ],
          ),
          Category(
              name: 'Orientierung & Technik',
              id: '1.4',
              subCategories: [
                Category(name: 'GPS-Geräte', id: '1.4.0'),
                Category(name: 'Kompasse', id: '1.4.1'),
                Category(name: 'Stirn & Taschenlampen', id: '1.4.2'),
                Category(name: 'Batterien & Akkus', id: '1.4.3'),
                Category(name: 'Kabel & Stecker', id: '1.4.4'),
                Category(name: 'Kameras', id: '1.4.5'),
                Category(name: 'Smartphone', id: '1.4.6'),
                Category(name: 'Uhr', id: '1.4.7'),
                Category(
                    name: 'Bücher & Karten',
                    id: '1.4.8',
                    subCategories: [
                      Category(name: 'Kletterführer', id: '1.4.8.0'),
                      Category(name: 'Trainings- & Lehrbücher', id: '1.4.8.1'),
                      Category(name: 'Wanderführer', id: '1.4.8.2'),
                      Category(name: 'Kartenmaterial', id: '1.4.8.3'),
                    ],
                    ),
                Category(name: 'Sonstige', id: '1.4.9'),
              ],
          ),
          Category(
              name: 'Outdoor Küche',
              id: '1.5',
              subCategories: [
                Category(
                    name: 'Trinkflaschen & Wasserträger',
                    id: '1.5.0',
                    subCategories: [
                      Category(name: 'Trinkflaschen', id: '1.5.0.0'),
                      Category(name: 'Thermoskannen', id: '1.5.0.1'),
                      Category(name: 'Trinkblasen', id: '1.5.0.2'),
                    ],
                    ),
                Category(name: 'Kocher', id: '1.5.1'),
                Category(name: 'Töpfe & Pfannen', id: '1.5.2'),
                Category(name: 'Geschirr & Besteck', id: '1.5.3'),
                Category(name: 'Behälter', id: '1.5.4'),
                Category(name: 'Grill & Feuer', id: '1.5.5'),
                Category(name: 'Sonstige', id: '1.5.6'),
              ],
              ),
          Category(
              name: 'Rucksäcke & Taschen',
              id: '1.6',
              subCategories: [
                Category(name: 'Packsäcke', id: '1.6.0'),
                Category(
                    name: 'Rucksäcke',
                    id: '1.6.1',
                    subCategories: [
                      Category(name: 'Hochtouren- & Kletterrucksäcke', id: '1.6.1.0'),
                      Category(name: 'Kraxen', id: '1.6.1.1'),
                      Category(name: 'Ski- & Lawinenrucksäcke', id: '1.6.1.2'),
                      Category(name: 'Trailrunning Rucksäcke', id: '1.6.1.3'),
                      Category(name: 'Wander- & Trekkingrucksäcke', id: '1.6.1.4'),
                      Category(name: 'Sonstige', id: '1.6.1.5'),
                    ],
                    ),
                Category(name: 'Schutzhüllen', id: '1.6.2'),
                Category(name: 'Taschen', id: '1.6.3'),
                Category(name: 'Sonstige', id: '1.6.4'),
              ],
              ),
          Category(
              name: 'Schlafen & Liegen',
              id: '1.7',
              subCategories: [
                Category(name: 'Biwaksäcke', id: '1.7.0'),
                Category(name: 'Decken', id: '1.7.1'),
                Category(name: 'Hängematte', id: '1.7.2'),
                Category(name: 'Isomatte', id: '1.7.3'),
                Category(name: 'Kissen', id: '1.7.4'),
                Category(name: 'Moskitonetze', id: '1.7.5'),
                Category(name: 'Schlafsack', id: '1.7.6'),
                Category(name: 'Tarps', id: '1.7.7'),
                Category(name: 'Zelte', id: '1.7.8'),
                Category(name: 'Sonstige', id: '1.7.9'),
              ],
              ),
          Category(name: 'Stöcke', id: '1.8'),
          Category(
              name: 'Wintersportausrüstung',
              id: '1.9',
              subCategories: [
                Category(name: 'Grödel & Spikes', id: '1.9.0'),
                Category(name: 'Rodel', id: '1.9.1'),
                Category(name: 'Schneeschuhe', id: '1.9.2'),
                Category(
                    name: 'Ski',
                    id: '1.9.3',
                    subCategories: [
                      Category(name: 'Bindungen', id: '1.9.3.0'),
                      Category(name: 'Harscheisen', id: '1.9.3.1'),
                      Category(name: 'Ski', id: '1.9.3.2'),
                      Category(name: 'Skifelle', id: '1.9.3.3'),
                      Category(name: 'Skihelme & Protektoren', id: '1.9.3.4'),
                    ],
                    ),
                Category(name: 'Sonstige', id: '1.9.4'),
              ],
              ),
        ],
    ),
    Category(
        name: 'Schuhe',
        id: '2',
        subCategories: [
          Category(name: 'Barfussschuhe', id: '2.0'),
          Category(name: 'Berg- & Wanderschuhe', id: '2.1'),
          Category(name: 'Hüttenschuhe', id: '2.2'),
          Category(name: 'Kletterschuhe', id: '2.3'),
          Category(name: 'Sandalen', id: '2.4'),
          Category(name: 'Trail- & Laufschuhe', id: '2.5'),
          Category(name: 'Winterschuhe', id: '2.6'),
          Category(name: 'Zustiegsschuhe', id: '2.7'),
          Category(name: 'Skischuhe', id: '2.8'),
          Category(name: 'Sonstige', id: '2.9'),
        ],
    ),
    Category(
      name: 'Verpflegung',
      id: '3',
      subCategories: [
        Category(name: 'Getränke', id: '3.0'),
        Category(name: 'Nahrung', id: '3.1'),
      ],
    ),
  ];

static List<String> getCategoryNames (String pCategoryId) {
    String categoryId = '$pCategoryId.';
    List<String> result = [];
    List<Category>? tempCategoryList = categories;
    List<Match> matches = RegExp('[.]').allMatches(categoryId).toList();

    for(int i = 0; i < (matches.length); i++) {
      Category tempCategory = tempCategoryList!.singleWhere((element) => element.id == categoryId.substring(0, matches[i].start));
      result.add(tempCategory.name);
      tempCategoryList = tempCategory.subCategories;
    }

    return result;
  }
}