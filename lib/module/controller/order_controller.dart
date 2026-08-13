import 'package:esdcustomer/config/api_constants.dart';
import 'package:esdcustomer/models/order_model.dart';
import 'package:esdcustomer/services/api_service.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class OrderController extends GetxController {
  final orders = <OrderModel>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  int _page = 1;
  final int _perPage = 15;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders({bool refresh = true}) async {
    if (refresh) {
      _page = 1;
      hasMore.value = true;
      isLoading.value = true;
    }
    try {
      final res = await ApiService.instance.get(ApiConstants.orders, query: {
        'page': _page,
        'per_page': _perPage,
      });

      final data = Map<String, dynamic>.from(res['data'] ?? {});
      final list = (data['orders'] as List<dynamic>? ?? [])
          .map((e) => OrderModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      if (refresh) {
        orders.value = list;
      } else {
        orders.addAll(list);
      }

      // Use the real pagination info instead of guessing from list length
      final pagination = Map<String, dynamic>.from(data['pagination'] ?? {});
      final currentPage = int.tryParse('${pagination['page'] ?? _page}') ?? _page;
      final totalPages = int.tryParse('${pagination['pages'] ?? 1}') ?? 1;
      hasMore.value = currentPage < totalPages;
    } on ApiException catch (e) {
      EasyLoading.showError(e.message);
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;
    isLoadingMore.value = true;
    _page++;
    await fetchOrders(refresh: false);
  }
}
