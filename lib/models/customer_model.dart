class CustomerModel {
  final int id;
  final String name;
  final String? phone;
  final String? email;
  final String? gst;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;

  CustomerModel({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.gst,
    this.address,
    this.city,
    this.state,
    this.pincode,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: int.tryParse('${json['id'] ?? json['customer_id']}') ?? 0,
      name: json['name']?.toString() ?? 'Customer',
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      gst: json['gst']?.toString(),
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      pincode: json['pincode']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'gst': gst,
        'address': address,
        'city': city,
        'state': state,
        'pincode': pincode,
      };
}
