class Category {
  final String name;
  final List<Category>? subCategories;
  final int id;

  Category({required this.id, this.subCategories, required this.name});
}