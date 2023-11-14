class CategoryModel {
  final int? id;
  final String? title;

  CategoryModel({
    this.id,
    this.title,
  });

  factory CategoryModel.fromJson(Map<dynamic, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int?,
      title: json['title'] as String?,
    );
  }


}
