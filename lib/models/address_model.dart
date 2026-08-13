class AddressModel {
  final int id;
  final String addressType; // billing | shipping | installation
  final String address;
  final String city;
  final String state;
  final String pincode;

  AddressModel({
    required this.id,
    required this.addressType,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: int.tryParse('${json['id']}') ?? 0,
      addressType: json['address_type']?.toString() ?? 'shipping',
      address: json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      pincode: json['pincode']?.toString() ?? '',
    );
  }

  String get label {
    switch (addressType) {
      case 'billing':
        return 'Billing';
      case 'installation':
        return 'Installation';
      case 'shipping':
      default:
        return 'Shipping';
    }
  }

  String get fullAddress => '$address, $city, $state - $pincode';
}