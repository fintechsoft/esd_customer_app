import 'package:esdcustomer/config/api_constants.dart';
import 'package:esdcustomer/models/ticket_model.dart';
import 'package:esdcustomer/services/api_service.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class SupportDetailController extends GetxController {
  final int ticketId;
  SupportDetailController(this.ticketId);

  final isLoading = false.obs;
  final isSending = false.obs;
  final Rxn<TicketModel> ticket = Rxn<TicketModel>();
  final replies = <TicketReplyModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    isLoading.value = true;
    try {
      // Matches CustomerSupportController::show($id) — {"data":{"ticket":{...},"replies":[...]}}
      final res = await ApiService.instance.get(ApiConstants.supportDetail(ticketId));
      final data = Map<String, dynamic>.from(res['data'] ?? {});

      ticket.value = TicketModel.fromJson(Map<String, dynamic>.from(data['ticket'] ?? {}));
      replies.value = (data['replies'] as List<dynamic>? ?? [])
          .map((e) => TicketReplyModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on ApiException catch (e) {
      EasyLoading.showError(e.message);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> sendReply(String message) async {
    if (message.trim().isEmpty) return false;
    isSending.value = true;
    try {
      await ApiService.instance.post(ApiConstants.supportReply(ticketId), data: {'message': message.trim()});
      // Re-fetch rather than optimistically appending — also picks up the
      // possible status change (reopened if it was resolved/closed).
      await fetchDetail();
      return true;
    } on ApiException catch (e) {
      EasyLoading.showError(e.message);
      return false;
    } finally {
      isSending.value = false;
    }
  }
}