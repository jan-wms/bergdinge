class Category {
  final String name;
  final List<Category>? subCategories;
  final String id;
  late String imageName;

  Category({required this.id, this.subCategories, required this.name, String? imageName}) {
    this.imageName = imageName ?? '$id.png';
  }
}