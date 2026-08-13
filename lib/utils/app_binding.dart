import 'package:esdcustomer/module/controller/address_controller.dart';
import 'package:esdcustomer/module/controller/auth_controller.dart';
import 'package:esdcustomer/module/controller/enquiry_controller.dart';
import 'package:esdcustomer/module/controller/order_controller.dart';
import 'package:esdcustomer/module/controller/product_controller.dart';
import 'package:esdcustomer/module/controller/support_controller.dart';
import 'package:get/get.dart';

class AppBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
    Get.lazyPut<OrderController>(() => OrderController(), fenix: true);
    Get.lazyPut<ProductController>(() => ProductController(), fenix: true);
    Get.lazyPut<SupportController>(() => SupportController(), fenix: true);
    Get.lazyPut<AddressController>(() => AddressController(), fenix: true);
    Get.lazyPut<EnquiryController>(() => EnquiryController(), fenix: true);
  }
}