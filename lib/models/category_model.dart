class CategoryModel {
  final int id;
  final String name;
  final int productCount;

  CategoryModel({required this.id, required this.name, required this.productCount});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: int.tryParse('${json['id']}') ?? 0,
      name: json['name']?.toString() ?? '',
      productCount: int.tryParse('${json['product_count'] ?? 0}') ?? 0,
    );
  }
}