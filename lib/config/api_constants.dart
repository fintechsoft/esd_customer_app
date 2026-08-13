class ApiConstants {
  // TODO: point this at your live domain (same backend as esdmanagement.in style)
  static const String baseUrl = 'https://esdmanagement.in';
  static const String apiBase = '$baseUrl/api';

  // Auth
  static const String sendOtp = '$apiBase/customer/auth/send-otp';
  static const String verifyOtp = '$apiBase/customer/auth/verify-otp';
  static const String me = '$apiBase/customer/auth/me';
  static const String logout = '$apiBase/customer/auth/logout';
  static const String profile = '$apiBase/customer/profile';

  // Orders / Bills
  static const String orders = '$apiBase/customer/orders';
  static String orderDetail(int id) => '$apiBase/customer/orders/$id';
  static String orderInstallation(int id) => '$apiBase/customer/orders/$id/installation';

  // Products (public catalog — CustomerProductController)
  static const String products = '$apiBase/customer/products';
  static const String productCategories = '$apiBase/customer/products/categories';
  static String productDetail(int id) => '$apiBase/customer/products/$id';
  static String productEnquiry(int id) => '$apiBase/customer/products/$id/enquiry';
  static const String contactEnquiry = '$apiBase/contact-enquiry';

  // Product enquiries submitted by the customer
  static const String enquiries = '$apiBase/customer/enquiries';

  // Support
  static const String support = '$apiBase/customer/support';
  static String supportDetail(int id) => '$apiBase/customer/support/$id';
  static String supportReply(int id) => '$apiBase/customer/support/$id/reply';

  // Addresses
  static const String addresses = '$apiBase/customer/addresses';
  static String addressDetail(int id) => '$apiBase/customer/addresses/$id';

  // External pages
  // TODO: Privacy Policy / Terms & Conditions are NOT live on
  // electronicssalesdelhi.com yet (checked — footer has no such links).
  // Update these once those pages exist. App/Play Store review checks that
  // this URL actually resolves, so don't submit with placeholders live.
  static const String privacyPolicyUrl = 'https://www.electronicssalesdelhi.com/privacy-policy';
  static const String termsUrl = 'https://www.electronicssalesdelhi.com/terms-and-conditions';
  static const String contactUsUrl = 'https://www.electronicssalesdelhi.com/contact';

  // Storage keys
  static const String storageToken = 'customer_token';
  static const String storageCustomer = 'customer_profile';
}