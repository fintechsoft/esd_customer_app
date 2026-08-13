import 'package:esdcustomer/config/api_constants.dart';
import 'package:esdcustomer/models/product_model.dart';
import 'package:esdcustomer/services/api_service.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class ProductDetailController extends GetxController {
  final int productId;
  ProductDetailController(this.productId);

  final isLoading = false.obs;
  final Rxn<ProductModel> product = Rxn<ProductModel>();
  final isSubmittingEnquiry = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    isLoading.value = true;
    try {
      // Matches CustomerProductController::show($id) — GET /customer/products/{id}
      final res = await ApiService.instance.get(ApiConstants.productDetail(productId));
      final data = res['data'] ?? res;
      product.value = ProductModel.fromJson(Map<String, dynamic>.from(data));
    } on ApiException catch (e) {
      EasyLoading.showError(e.message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendEnquiry({required String message}) async {
    isSubmittingEnquiry.value = true;
    try {
      // Name/phone are NOT sent — the backend pulls them from the
      // authenticated customer's own token instead of trusting client
      // input, so the enquiry can't be submitted as someone else.
      await ApiService.instance.post(ApiConstants.productEnquiry(productId), data: {
        'message': message,
      });
      EasyLoading.showSuccess('Enquiry sent! Our team will reach out shortly.');
    } on ApiException catch (e) {
      EasyLoading.showError(e.message);
    } finally {
      isSubmittingEnquiry.value = false;
    }
  }
}