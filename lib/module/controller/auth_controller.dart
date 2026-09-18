import 'dart:async';

import 'package:esdcustomer/config/api_constants.dart';
import 'package:esdcustomer/models/customer_model.dart';
import 'package:esdcustomer/module/view/auth/complete_profile_screen.dart';
import 'package:esdcustomer/module/view/auth/otp_screen.dart';
import 'package:esdcustomer/module/view/main_nav.dart';
import 'package:esdcustomer/module/view/splash_screen.dart';
import 'package:esdcustomer/services/api_service.dart';
import 'package:esdcustomer/services/push_notification_service.dart';
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

  /// True while the App Store / Play Store review demo number is being used.
  bool get _isDemoPhone => phone.value == ApiConstants.demoPhone;

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
    // App review demo number: skip the SMS request entirely and go straight
    // to the OTP screen, where ApiConstants.demoOtp is accepted.
    if (mobile == ApiConstants.demoPhone) {
      phone.value = mobile;
      _startResendTimer();
      Get.to(() => OtpScreen(phone: mobile));
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
    if (_isDemoPhone) {
      _startResendTimer();
      return;
    }
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
    // App review demo login: the fixed pair below is the only case that may
    // bypass the SMS flow. We still hit the backend first so the reviewer gets
    // a real session with real data; only if that call fails do we fall back
    // to a local demo session so the build is never un-reviewable.
    if (_isDemoPhone && otp != ApiConstants.demoOtp) {
      EasyLoading.showError('Incorrect OTP. Please try again.');
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
        if (_isDemoPhone) {
          await _startDemoSession();
          return;
        }
        EasyLoading.showError('Login failed. Please try again.');
        return;
      }

      await _box.write(ApiConstants.storageToken, token);
      await _box.write(ApiConstants.storageCustomer, customerJson);
      customer.value = CustomerModel.fromJson(customerJson);

      // The device token could only be attached to a customer once we hold a
      // bearer token, so push it now rather than at app start.
      unawaited(PushNotificationService.instance.syncToken());

      // The review demo account never goes through profile completion.
      if (isNew && !_isDemoPhone) {
        Get.offAll(() => CompleteProfileScreen());
      } else {
        Get.offAll(() => const MainNav());
      }
    } on ApiException catch (e) {
      if (_isDemoPhone) {
        await _startDemoSession();
        return;
      }
      EasyLoading.showError(e.message);
    } finally {
      isVerifying.value = false;
    }
  }

  /// Offline fallback for the review demo number when the backend has not (yet)
  /// been given the demo account. Keeps the reviewer out of a dead end.
  Future<void> _startDemoSession() async {
    const demoCustomer = {
      'id': 0,
      'name': 'Demo Customer',
      'phone': ApiConstants.demoPhone,
      'email': 'demo@electronicssalesdelhi.com',
    };
    await _box.write(ApiConstants.storageToken, 'demo-review-session');
    await _box.write(ApiConstants.storageCustomer, demoCustomer);
    customer.value = CustomerModel.fromJson(Map<String, dynamic>.from(demoCustomer));
    Get.offAll(() => const MainNav());
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

  /// Permanently deletes the customer account — required by App Store Review
  /// Guideline 5.1.1(v) for any app that lets users create an account.
  Future<bool> deleteAccount() async {
    isVerifying.value = true;
    try {
      await ApiService.instance.delete(ApiConstants.deleteAccount);
      await _clearSession();
      Get.offAll(() => const SplashScreen());
      EasyLoading.showSuccess('Your account has been deleted');
      return true;
    } on ApiException catch (e) {
      EasyLoading.showError(e.message);
      return false;
    } finally {
      isVerifying.value = false;
    }
  }

  Future<void> _clearSession() async {
    // Detach first — it needs the bearer token that is about to be cleared.
    await PushNotificationService.instance.unregisterToken();
    await _box.remove(ApiConstants.storageToken);
    await _box.remove(ApiConstants.storageCustomer);
    customer.value = null;
  }

  Future<void> logout() async {
    try {
      await ApiService.instance.post(ApiConstants.logout);
    } catch (_) {
      // ignore network errors on logout — clear local session regardless
    }
    await _clearSession();
    Get.offAll(() => const SplashScreen());
  }
}