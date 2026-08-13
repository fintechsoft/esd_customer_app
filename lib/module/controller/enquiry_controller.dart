import 'package:esdcustomer/config/api_constants.dart';
import 'package:esdcustomer/models/enquiry_model.dart';
import 'package:esdcustomer/services/api_service.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class EnquiryController extends GetxController {
  final enquiries = <EnquiryModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchEnquiries();
  }

  Future<void> fetchEnquiries() async {
    isLoading.value = true;
    try {
      final res = await ApiService.instance.get(ApiConstants.enquiries);
      print(res);
      final data = Map<String, dynamic>.from(res['data'] ?? {});
      enquiries.value = (data['enquiries'] as List<dynamic>? ?? [])
          .map((e) => EnquiryModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on ApiException catch (e) {
      EasyLoading.showError(e.message);
    } finally {
      isLoading.value = false;
    }
  }
}