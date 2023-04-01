class Data {
  final List<String> _sports = [
    'Wandern',
    'Klettern',
    'Hochtour',
    'Ski',
    'Skitour',
    'Sportklettern',
    'Mehrtagestour',
    'Tagestour',
  ];

  final _categories = {
    'Bekleidung': {
      'Jacken': {
        'Hardshelljacke',
        'Softshelljacke',
        'Isolationsjacke',
        'Fleecejacke',
        'Woll- & Merinojacken',
        'Windbreaker',
        'Skijacke',
        'Poncho',
        'Sonstige',
      },
      'Hosen': {
        'Skihose',
        'Trekkinghose',
        'Hochtourenhose',
        'Kletterhose',
        'Hardshellhose',
        'Winterhose',
        'Softshellhose',
        'Laufhose',
        'Trainingshose',
        'Skitourenhose',
        'Fleecehose',
        'Isolationshose',
        'Tights',
        'Shorts',
      },
    },
    'Schuhe': null,
    'Ausrüstung': {
      'Rucksäck': {
        'Wanderrucksack',
        'Kletterrucksack',
        'Hochtourenrucksack',
        'Lawinenrucksack',
        'Trailrunningweste',
      },
      'Notfallausrüstung': {
        'Erste Hilfe',
        'Lawinenausrüstung',
        'Biwaksack',
      },

    },
  };

  List<String> get sports => _sports;

  Map<String, Map<String, Set<String>?>?> get categories => _categories;
}
