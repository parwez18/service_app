class CategoriesModel {
  final String id;
  final String title;
  final String parent;
  final String logoPath;

  CategoriesModel({
    required this.id,
    required this.title,
    required this.parent,
    required this.logoPath,
  });

  factory CategoriesModel.fromDoc(Map<String, dynamic> data, String id) {
    return CategoriesModel(
      id: id,
      title: data['title'] ?? '',
      parent: data['parent'] ?? '',
      logoPath: data['logoPath'] ?? '',
    );
  }
}
