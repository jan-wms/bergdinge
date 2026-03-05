import 'package:bergdinge/models/category.dart';
import 'package:flutter/material.dart';

class CategoryData {
  CategoryData._();

  static List<Category> categories = [
    Category(name: 'Bekleidung', id: '0', subCategories: [
      Category(name: 'Accessories', id: '0.0', subCategories: [
        Category(name: 'Brillen', id: '0.0.0'),
        Category(name: 'Handschuhe', id: '0.0.1'),
        Category(name: 'Mützen & Stirnbänder', id: '0.0.2'),
        Category(name: 'Caps & Hüte', id: '0.0.3'),
        Category(name: 'Tücher & Schals', id: '0.0.4'),
        Category(name: 'Socken', id: '0.0.5'),
        Category(name: 'Unterwäsche', id: '0.0.6'),
      ]),
      Category(
        name: 'Jacken & Westen',
        id: '0.1',
        subCategories: [
          Category(name: 'Hardshell- & Skijacken', id: '0.1.0'),
          Category(name: 'Isolationsjacken', id: '0.1.1'),
          Category(name: 'Softshelljacken & Windbreaker', id: '0.1.2'),
          Category(name: 'Westen', id: '0.1.3'),
        ],
      ),
      Category(name: 'Oberteile', id: '0.2', subCategories: [
        Category(name: 'T-Shirts', id: '0.2.0'),
        Category(name: 'Fleece & Midlayer', id: '0.2.1'),
        Category(name: 'Hemden', id: '0.2.2'),
        Category(name: 'Longsleeves', id: '0.2.3'),
        Category(name: 'Tops', id: '0.2.4'),
      ]),
      Category(
        name: 'Hosen',
        id: '0.3',
        subCategories: [
          Category(name: 'Hardshell- & Skihosen', id: '0.3.0'),
          Category(name: 'Softshell- & Trekkinghosen', id: '0.3.1'),
          Category(name: 'Shorts & Laufhosen', id: '0.3.2'),
          Category(name: 'Kletterhosen', id: '0.3.3'),
          Category(name: 'Isolationshosen', id: '0.3.4'),
        ],
      ),
      Category(name: 'Sonstige Bekleidung', id: '0.4')
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
          ],
        ),
        Category(
          name: 'Klettern',
          id: '1.1',
          subCategories: [
            Category(name: 'Kletterhelm', id: '1.1.0'),
            Category(name: 'Klettergurt', id: '1.1.1'),
            Category(name: 'Seilklemmen', id: '1.1.2'),
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
                Category(name: 'Crashpads', id: '1.1.5.1'),
                Category(name: 'Griffbürsten', id: '1.1.5.2'),
              ],
            ),
            Category(
              name: 'Karabiner & Expressen',
              id: '1.1.6',
              subCategories: [
                Category(name: 'Verschlusskarabiner', id: '1.1.6.0'),
                Category(name: 'Schnappkarabiner', id: '1.1.6.1'),
                Category(name: 'Express-Schlingen', id: '1.1.6.2'),
              ],
            ),
            Category(
              name: 'Seile, Schlingen & Reepschnüre',
              id: '1.1.7',
              subCategories: [
                Category(name: 'Bandschlingen', id: '1.1.7.0'),
                Category(name: 'Reepschnüre', id: '1.1.7.1'),
                Category(name: 'Kletterseile', id: '1.1.7.2'),
                Category(name: 'Seilsäcke', id: '1.1.7.3'),
              ],
            ),
            Category(name: 'Klemmgeräte & Friends', id: '1.1.8', imageName: '1.1.3.png'),
          ],
        ),
        Category(
          name: 'Messer & Werkzeuge',
          id: '1.2',
          subCategories: [
            Category(name: 'Äxte & Beile', id: '1.2.0'),
            Category(name: 'Feststehende Messer', id: '1.2.1'),
            Category(name: 'Taschenmesser und Multitools', id: '1.2.2'),
          ],
        ),
        Category(
          name: 'Notfall- & Lawinenausrüstung',
          id: '1.3',
          subCategories: [
            Category(name: 'Notfall-Biwaksack', id: '1.3.0', imageName: '1.7.0.png'),
            Category(name: 'Erste Hilfe', id: '1.3.1'),
            Category(name: 'LVS-Geräte', id: '1.3.2'),
            Category(name: 'Schaufeln', id: '1.3.3'),
            Category(name: 'Sonden', id: '1.3.4'),
          ],
        ),
        Category(
          name: 'Orientierung & Technik',
          id: '1.4',
          subCategories: [
            Category(name: 'Bücher', id: '1.4.0'),
            Category(name: 'GPS', id: '1.4.1'),
            Category(name: 'Lampen', id: '1.4.2'),
            Category(name: 'Karten', id: '1.4.3'),
            Category(name: 'Kompass', id: '1.4.4'),
            Category(name: 'Smartphones & Kameras', id: '1.4.5'),
            Category(name: 'Uhren', id: '1.4.6'),
            Category(name: 'Zubehör (Akkus, Kabel)', id: '1.4.7'),
          ],
        ),
        Category(
          name: 'Outdoor Küche',
          id: '1.5',
          subCategories: [
            Category(name: 'Behälter', id: '1.5.0'),
            Category(name: 'Geschirr & Besteck', id: '1.5.1'),
            Category(name: 'Töpfe & Pfannen', id: '1.5.2'),
            Category(name: 'Grill & Feuer', id: '1.5.3'),
            Category(name: 'Kocher', id: '1.5.4'),
            Category(name: 'Thermoskannen', id: '1.5.5'),
            Category(name: 'Trinkflaschen & Trinkblasen', id: '1.5.6'),
          ],
        ),
        Category(
          name: 'Rucksäcke & Taschen',
          id: '1.6',
          subCategories: [
            Category(name: 'Packsäcke', id: '1.6.0'),
            Category(name: 'Rucksäcke', id: '1.6.1'),
            Category(name: 'Taschen', id: '1.6.2'),
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
            Category(name: 'Schlafsäcke', id: '1.7.6'),
            Category(name: 'Zelte & Tarps', id: '1.7.7'),
          ],
        ),
        Category(name: 'Ski & Skitour', id: '1.8', subCategories: [
          Category(name: 'Ski', id: '1.8.0'),
          Category(name: 'Harscheisen', id: '1.8.1'),
          Category(name: 'Skifelle', id: '1.8.2'),
          Category(name: 'Skihelme & Protektoren', id: '1.8.3'),
        ]),
        Category(
          name: 'Wintersport',
          id: '1.9',
          subCategories: [
            Category(name: 'Grödel & Spikes', id: '1.9.0'),
            Category(name: 'Rodel', id: '1.9.1'),
            Category(name: 'Schneeschuhe', id: '1.9.2'),
          ],
        ),
        Category(name: 'Stöcke', id: '1.10'),
        Category(name: 'Sonstige Ausrüstung', id: '1.11'),
      ],
    ),
    Category(
      name: 'Schuhe',
      id: '2',
      subCategories: [
        Category(name: 'Berg- & Wanderschuhe', id: '2.0'),
        Category(name: 'Zustiegsschuhe', id: '2.1'),
        Category(name: 'Trail- & Laufschuhe', id: '2.2'),
        Category(name: 'Kletterschuhe', id: '2.3'),
        Category(name: 'Skischuhe', id: '2.4'),
        Category(name: 'Hüttenschuhe', id: '2.5'),
        Category(name: 'Sonstige Schuhe', id: '2.6', imageName: '2.0.png'),
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


  static List<Category> flatMapCategories(String pCategoryId) {
    String categoryId = '$pCategoryId.';
    List<Category> result = [];
    List<Category>? tempCategoryList = CategoryData.categories;
    List<Match> matches = RegExp('[.]').allMatches(categoryId).toList();

    for (int i = 0; i < (matches.length); i++) {
      Category tempCategory = tempCategoryList!.singleWhere(
              (element) => element.id == categoryId.substring(0, matches[i].start));
      result.add(tempCategory);
      tempCategoryList = tempCategory.subCategories;
    }

    return result;
  }

  static String getCategoryImageName(String pCategoryId) {
    List<Category> categories = flatMapCategories(pCategoryId);
    return categories.last.imageName;
  }

  static Widget getImagefromCategory({required String category}) {
    String imageName = getCategoryImageName(category);
    return ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 1,
          minHeight: 1,
        ),
        child: Image.asset('assets/items/$imageName',
            errorBuilder: (context, object, stacktrace) => Image.asset(
              'assets/items/1.11.png',
            )));
  }
}