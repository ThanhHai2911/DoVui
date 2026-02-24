class CategoryModel {
  final String id;
  final String name;
  final String image;

  CategoryModel({
    required this.id,
    required this.name,
    required this.image,
  });

  factory CategoryModel.fromDoc(doc) {
    return CategoryModel(
      id: doc.id,
      name: doc["name"],
      image: doc["image"],
    );
  }
}