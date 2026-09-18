class ApiConstants {
  // TODO: point this at your live domain (same backend as esdmanagement.in style)
  static const String baseUrl = 'https://esdmanagement.in';
  static const String apiBase = '$baseUrl/api';

  // Auth
  static const String sendOtp = '$apiBase/customer/auth/send-otp';
  static const String verifyOtp = '$apiBase/customer/auth/verify-otp';
  static const String me = '$apiBase/customer/auth/me';
  static const String logout = '$apiBase/customer/auth/logout';
  static const String deleteAccount = '$apiBase/customer/auth/account';

  // Push notifications — the CI4 backend stores one row per device token so it
  // can target a single customer or broadcast to everyone.
  static const String registerDevice = '$apiBase/customer/devices/register';
  static const String unregisterDevice = '$apiBase/customer/devices/unregister';
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
  // esdmanagement.in yet (checked — footer has no such links).
  // Update these once those pages exist. App/Play Store review checks that
  // this URL actually resolves, so don't submit with placeholders live.
  static const String privacyPolicyUrl = 'https://www.esdmanagement.in/privacy-policy';
  static const String termsUrl = 'https://www.esdmanagement.in/terms-and-conditions';
  static const String contactUsUrl = 'https://www.esdmanagement.in/contact';

  // --- App Store / Play Store review demo account -------------------------
  // Apple's review team cannot receive an Indian SMS OTP, so this one number
  // skips the SMS step and accepts a fixed OTP. These exact values are filled
  // into App Store Connect > App Review Information > Sign-In Information.
  // The backend must recognise the same pair, otherwise the reviewer logs in
  // to an empty app and we get a Guideline 2.1 rejection anyway.
  static const String demoPhone = '9876543210';
  static const String demoOtp = '123456';

  // Storage keys
  static const String storageToken = 'customer_token';
  static const String storageCustomer = 'customer_profile';
  static const String storageFcmToken = 'customer_fcm_token';
}