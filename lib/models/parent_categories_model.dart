class ParentCategoriesModel {
  final String id;
  final String title;

  ParentCategoriesModel({required this.id, required this.title});

  factory ParentCategoriesModel.fromDoc(Map<String, dynamic> data, String id) {
    return ParentCategoriesModel(id: id, title: data['title'] ?? '');
  }
}
