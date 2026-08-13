class EnquiryModel {
  final int id;
  final String product;
  final String? remarks;
  final String status; // New | Contacted | Qualified | Lost | Closed
  final String createdAt;

  EnquiryModel({
    required this.id,
    required this.product,
    this.remarks,
    required this.status,
    required this.createdAt,
  });

  factory EnquiryModel.fromJson(Map<String, dynamic> json) {
    return EnquiryModel(
      id: int.tryParse('${json['id']}') ?? 0,
      product: json['product']?.toString() ?? '',
      remarks: json['remarks']?.toString(),
      status: json['status']?.toString() ?? 'New',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}