// import 'dart:io';
//
// import 'package:dio/dio.dart';
// import 'package:esdcustomer/config/api_constants.dart';
// import 'package:esdcustomer/models/ticket_model.dart';
// import 'package:esdcustomer/services/api_service.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:get/get.dart' hide MultipartFile, FormData;
//
// class SupportController extends GetxController {
//   final tickets = <TicketModel>[].obs;
//   final isLoading = false.obs;
//   final isSubmitting = false.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchTickets();
//   }
//
//   Future<void> fetchTickets() async {
//     isLoading.value = true;
//     try {
//       final res = await ApiService.instance.get(ApiConstants.support);
//       final data = Map<String, dynamic>.from(res['data'] ?? {});
//       tickets.value = (data['tickets'] as List<dynamic>? ?? [])
//           .map((e) => TicketModel.fromJson(Map<String, dynamic>.from(e)))
//           .toList();
//     } on ApiException catch (e) {
//       EasyLoading.showError(e.message);
//     } finally {
//       isLoading.value = false;
//     }
//   }
//
//   Future<bool> raiseTicket({
//     required String subject,
//     required String message,
//     required String category,
//     required int orderId,
//     File? attachment,
//   }) async {
//     isSubmitting.value = true;
//     try {
//       final formMap = <String, dynamic>{
//         'subject': subject,
//         'message': message,
//         'category': category,
//         'order_id': orderId,
//       };
//       if (attachment != null) {
//         formMap['attachment'] = await MultipartFile.fromFile(attachment.path);
//       }
//       final form = FormData.fromMap(formMap);
//       await ApiService.instance.postForm(ApiConstants.support, form);
//       EasyLoading.showSuccess('Support request raised');
//       await fetchTickets();
//       return true;
//     } on ApiException catch (e) {
//       EasyLoading.showError(e.message); print(e.message);
//       return false;
//     } finally {
//       isSubmitting.value = false;
//     }
//   }
// }
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:esdcustomer/config/api_constants.dart';
import 'package:esdcustomer/models/ticket_model.dart';
import 'package:esdcustomer/services/api_service.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart' hide MultipartFile, FormData;

class SupportController extends GetxController {
  final tickets = <TicketModel>[].obs;
  final isLoading = false.obs;
  final isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTickets();
  }

  Future<void> fetchTickets() async {
    isLoading.value = true;
    try {
      final res = await ApiService.instance.get(ApiConstants.support);
      final data = Map<String, dynamic>.from(res['data'] ?? {});
      tickets.value = (data['tickets'] as List<dynamic>? ?? [])
          .map((e) => TicketModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on ApiException catch (e) {
      EasyLoading.showError(e.message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> raiseTicket({
    required String subject,
    required String message,
    required String category,
    required int orderId,
    File? attachment,
  }) async {
    isSubmitting.value = true;
    try {
      final formMap = <String, dynamic>{
        'subject': subject,
        'message': message,
        'category': category,
        'order_id': orderId,
      };
      if (attachment != null) {
        formMap['attachment'] = await MultipartFile.fromFile(attachment.path);
      }
      final form = FormData.fromMap(formMap);
      await ApiService.instance.postForm(ApiConstants.support, form);
      EasyLoading.showSuccess('Support request raised');
      await fetchTickets();
      return true;
    } on ApiException catch (e) {
      EasyLoading.showError(e.message);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}