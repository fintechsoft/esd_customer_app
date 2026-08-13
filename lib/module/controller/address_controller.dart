import 'package:esdcustomer/config/api_constants.dart';
import 'package:esdcustomer/models/address_model.dart';
import 'package:esdcustomer/services/api_service.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class AddressController extends GetxController {
  final addresses = <AddressModel>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAddresses();
  }

  Future<void> fetchAddresses() async {
    isLoading.value = true;
    try {
      final res = await ApiService.instance.get(ApiConstants.addresses);
      final data = Map<String, dynamic>.from(res['data'] ?? {});
      addresses.value = (data['addresses'] as List<dynamic>? ?? [])
          .map((e) => AddressModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on ApiException catch (e) {
      EasyLoading.showError(e.message);
    } finally {
      isLoading.value = false;
    }
  }

  /// Creates one address row per selected type — lets a customer save the
  /// same address text as billing + shipping + installation in one go
  /// instead of retyping it for each.
  Future<bool> createAddress({
    required List<String> addressTypes,
    required String address,
    required String city,
    required String state,
    required String pincode,
  }) async {
    isSaving.value = true;
    try {
      await ApiService.instance.post(ApiConstants.addresses, data: {
        'address_types': addressTypes,
        'address': address,
        'city': city,
        'state': state,
        'pincode': pincode,
      });
      await fetchAddresses();
      return true;
    } on ApiException catch (e) {
      EasyLoading.showError(e.message);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Editing an existing row always maps to exactly one type — it's one
  /// saved record, not a fresh multi-type save.
  Future<bool> updateAddress({
    required int id,
    required String addressType,
    required String address,
    required String city,
    required String state,
    required String pincode,
  }) async {
    isSaving.value = true;
    try {
      await ApiService.instance.put(ApiConstants.addressDetail(id), data: {
        'address_type': addressType,
        'address': address,
        'city': city,
        'state': state,
        'pincode': pincode,
      });
      await fetchAddresses();
      return true;
    } on ApiException catch (e) {
      EasyLoading.showError(e.message);
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> deleteAddress(int id) async {
    try {
      await ApiService.instance.delete(ApiConstants.addressDetail(id));
      addresses.removeWhere((a) => a.id == id);
      return true;
    } on ApiException catch (e) {
      EasyLoading.showError(e.message);
      return false;
    }
  }
}