import 'package:bergdinge/models/equipment.dart';
import 'package:bergdinge/models/packing_plan.dart';
import 'package:bergdinge/models/packing_plan_item.dart';
import 'package:bergdinge/models/packing_plan_location.dart';

class ExampleData {
  const ExampleData._();

  static final List<Equipment> equipment = [
    Equipment(brand: '', size: '', uvp: 90.0, price: 70.0, name: 'Skibrille', weight: 170, category: '0.0.0', count: 1, id: 'example-00'),
    Equipment(brand: '', size: '', price: 50.0, purchaseDate: DateTime(DateTime.now().year, 1, 1), name: 'Handschuhe', weight: 280, category: '0.0.1', count: 1, id: 'example-01'),
    Equipment(brand: '', size: 'M', name: 'Daunenjacke', weight: 500, category: '0.1.1', count: 1, id: 'example-02'),
    Equipment(brand: '', size: 'M', uvp: 499.0, price: 399.0, name: 'Hardshelljacke', weight: 600, category: '0.1.0', count: 1, id: 'example-03'),
    Equipment(brand: '', size: '', name: 'Hardshellhose', weight: 500, category: '0.3.0', count: 1, id: 'example-04'),
    Equipment(brand: '', size: '', price: 14.9, name: 'HMS-Karabiner', weight: 50, category: '1.1.6.0', count: 3, id: 'example-05'),
    Equipment(brand: '', size: 'M/L', name: 'Kletterhelm', weight: 300, category: '1.1.0', count: 1, id: 'example-06'),
    Equipment(brand: '', size: '', name: 'Steigeisen', weight: 1100, category: '1.1.4.0', count: 1, id: 'example-07'),
    Equipment(brand: '', size: '60m', name: 'Einfachseil', weight: 3100, category: '1.1.7.2', count: 1, id: 'example-08'),
    Equipment(brand: '', size: '35 Liter', purchaseDate: DateTime(DateTime.now().year, 1, 1), name: 'Wanderrucksack', weight: 1300, category: '1.6.1', count: 1, id: 'example-09'),
    Equipment(brand: '', size: '', name: 'Bergschuhe', weight: 1320, category: '2.0', count: 1, id: 'example-10'),
    Equipment(brand: '', size: 'Onesize', purchaseDate: DateTime(DateTime.now().year, 4, 1), name: 'Hüttenschuhe', weight: 300, category: '2.5', count: 1, id: 'example-11'),
    Equipment(brand: '', size: '', name: 'Wasser', weight: 1, category: '3.0', count: 1, id: 'example-12'),
  ];

  static final PackingPlan packingPlan = PackingPlan(name: 'Beispiel Hochtour', sports: [
    'Hochtour',
    'Mehrtagestour',
    'Hüttentour',
  ], id: 'example');

  static final List<PackingPlanItem> packingPlanItems = [
    PackingPlanItem(equipmentCount: 1, equipmentId: 'example-00', isChecked: false, location: PackingPlanLocation.backpack),
    PackingPlanItem(equipmentCount: 1, equipmentId: 'example-02', isChecked: false, location: PackingPlanLocation.backpack),
    PackingPlanItem(equipmentCount: 3, equipmentId: 'example-05', isChecked: false, location: PackingPlanLocation.backpack),
    PackingPlanItem(equipmentCount: 1, equipmentId: 'example-07', isChecked: false, location: PackingPlanLocation.backpack),
    PackingPlanItem(equipmentCount: 1, equipmentId: 'example-09', isChecked: false, location: PackingPlanLocation.backpack),
    PackingPlanItem(equipmentCount: 1, equipmentId: 'example-11', isChecked: false, location: PackingPlanLocation.backpack),
    PackingPlanItem(equipmentCount: 2000, equipmentId: 'example-12', isChecked: false, location: PackingPlanLocation.backpack),

    PackingPlanItem(equipmentCount: 2, equipmentId: 'example-01', isChecked: false, location: PackingPlanLocation.person),
    PackingPlanItem(equipmentCount: 1, equipmentId: 'example-03', isChecked: false, location: PackingPlanLocation.person),
    PackingPlanItem(equipmentCount: 1, equipmentId: 'example-04', isChecked: false, location: PackingPlanLocation.person),
    PackingPlanItem(equipmentCount: 1, equipmentId: 'example-10', isChecked: false, location: PackingPlanLocation.person),
  ];
}