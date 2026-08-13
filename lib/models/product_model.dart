class ProductModel {
  final int id;
  final String name;
  final String? img;
  final String? code;
  final double cost;
  final String? details;
  final String? color;
  final int? warranty;
  final String? brandName;
  final String? categoryName;
  final bool inStock;

  ProductModel({
    required this.id,
    required this.name,
    this.img,
    this.code,
    required this.cost,
    this.details,
    this.color,
    this.warranty,
    this.brandName,
    this.categoryName,
    this.inStock = true,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: int.tryParse('${json['id']}') ?? 0,
      name: json['name']?.toString() ?? '',
      img: json['img']?.toString(),
      code: json['code']?.toString(),
      cost: double.tryParse('${json['cost'] ?? 0}') ?? 0,
      details: json['details']?.toString(),
      color: json['color']?.toString(),
      warranty: int.tryParse('${json['warranty'] ?? ''}'),
      brandName: json['brand_name']?.toString() ?? json['brand']?.toString(),
      categoryName: json['category_name']?.toString() ?? json['category']?.toString(),
      inStock: json['in_stock'] == true || json['in_stock'] == 1 || json['in_stock'] == '1',
    );
  }
}
