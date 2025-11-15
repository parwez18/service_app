class CategoriesModel {
  final String id;
  final String title;

  CategoriesModel({required this.id, required this.title});

  factory CategoriesModel.fromDoc(Map<String, dynamic> data, String id) {
    return CategoriesModel(id: id, title: data['title'] ?? '');
  }
}
