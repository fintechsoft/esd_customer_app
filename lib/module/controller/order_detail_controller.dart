import 'package:esdcustomer/config/api_constants.dart';
import 'package:esdcustomer/models/order_model.dart';
import 'package:esdcustomer/services/api_service.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderDetailController extends GetxController {
  final int orderId;
  OrderDetailController(this.orderId);

  final isLoading = false.obs;
  final Rxn<OrderDetailModel> detail = Rxn<OrderDetailModel>();

  @override
  void onInit() {
    super.onInit();
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    isLoading.value = true;
    try {
      final res = await ApiService.instance.get(ApiConstants.orderDetail(orderId));
      print("Details is $res");
      final Items=res['data']['items'];
      print("Item details is $Items");
      final exItems=res['data']['exchange_items'];
      print("Ex Item details is $exItems");
      final data = Map<String, dynamic>.from(res['data'] ?? {});
      detail.value = OrderDetailModel.fromJson(data);

    } on ApiException catch (e) {
      EasyLoading.showError(e.message);
    } finally {
      isLoading.value = false;
    }
  }

  // Future<void> openPdf(String? url) async {
  //   if (url == null || url.isEmpty) {
  //     EasyLoading.showToast('Bill PDF not available yet');
  //     return;
  //   }
  //   final uri = Uri.parse(url);
  //   if (await canLaunchUrl(uri)) {
  //     await launchUrl(uri, mode: LaunchMode.externalApplication);
  //   } else {
  //     EasyLoading.showError('Could not open the file');
  //   }
  // }
}
