import 'package:esdcustomer/config/api_constants.dart';
import 'package:esdcustomer/models/customer_model.dart';
import 'package:esdcustomer/module/view/auth/complete_profile_screen.dart';
import 'package:esdcustomer/module/view/auth/otp_screen.dart';
import 'package:esdcustomer/module/view/main_nav.dart';
import 'package:esdcustomer/module/view/splash_screen.dart';
import 'package:esdcustomer/services/api_service.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthController extends GetxController {
  final _box = GetStorage();

  final phone = ''.obs;
  final isSendingOtp = false.obs;
  final isVerifying = false.obs;
  final resendSeconds = 0.obs;

  final Rxn<CustomerModel> customer = Rxn<CustomerModel>();

  bool get isLoggedIn => (_box.read(ApiConstants.storageToken) ?? '').toString().isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    final saved = _box.read(ApiConstants.storageCustomer);
    if (saved != null) {
      customer.value = CustomerModel.fromJson(Map<String, dynamic>.from(saved));
    }
  }

  Future<void> sendOtp(String mobile) async {
    if (mobile.length != 10) {
      EasyLoading.showError('Enter a valid 10 digit mobile number');
      return;
    }
    isSendingOtp.value = true;
    try {
      await ApiService.instance.post(ApiConstants.sendOtp, data: {'phone': mobile});
      phone.value = mobile;
      _startResendTimer();
      Get.to(() => OtpScreen(phone: mobile));
    } on ApiException catch (e) {
      EasyLoading.showError(e.message);
    } finally {
      isSendingOtp.value = false;
    }
  }

  Future<void> resendOtp() async {
    if (resendSeconds.value > 0) return;
    await sendOtp(phone.value);
  }

  void _startResendTimer() {
    resendSeconds.value = 30;
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (resendSeconds.value > 0) resendSeconds.value--;
      return resendSeconds.value > 0;
    });
  }

  Future<void> verifyOtp(String otp) async {
    if (otp.length != 6) {
      EasyLoading.showError('Enter the 6 digit OTP');
      return;
    }
    isVerifying.value = true;
    try {
      final res = await ApiService.instance.post(ApiConstants.verifyOtp, data: {
        'phone': phone.value,
        'otp': otp,
        'device_info': 'flutter-app',
      });

      final data = Map<String, dynamic>.from(res['data'] ?? {});
      final token = data['token']?.toString() ?? '';
      final isNew = data['is_new'] == true;
      final customerJson = Map<String, dynamic>.from(data['customer'] ?? {});

      if (token.isEmpty) {
        EasyLoading.showError('Login failed. Please try again.');
        return;
      }

      await _box.write(ApiConstants.storageToken, token);
      await _box.write(ApiConstants.storageCustomer, customerJson);
      customer.value = CustomerModel.fromJson(customerJson);

      if (isNew) {
        Get.offAll(() => CompleteProfileScreen());
      } else {
        Get.offAll(() => const MainNav());
      }
    } on ApiException catch (e) {
      EasyLoading.showError(e.message);
    } finally {
      isVerifying.value = false;
    }
  }

  /// Called from CompleteProfileScreen right after a first-time signup.
  Future<bool> completeProfile({
    required String name,
    String gst = '',
  }) async {
    isVerifying.value = true;
    try {
      final res = await ApiService.instance.put(ApiConstants.profile, data: {
        'name': name,
        'gst': gst,
      });

      final data = Map<String, dynamic>.from(res['data'] ?? {});
      await _box.write(ApiConstants.storageCustomer, data);
      customer.value = CustomerModel.fromJson(data);

      Get.offAll(() => const MainNav());
      return true;
    } on ApiException catch (e) {
      EasyLoading.showError(e.message);
      return false;
    } finally {
      isVerifying.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await ApiService.instance.post(ApiConstants.logout);
    } catch (_) {
      // ignore network errors on logout — clear local session regardless
    }
    await _box.remove(ApiConstants.storageToken);
    await _box.remove(ApiConstants.storageCustomer);
    customer.value = null;
    Get.offAll(() => const SplashScreen());
  }
}