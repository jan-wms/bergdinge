class Category {
  final String name;
  final List<Category>? subCategories;
  final String id;

  Category({required this.id, this.subCategories, required this.name});
}