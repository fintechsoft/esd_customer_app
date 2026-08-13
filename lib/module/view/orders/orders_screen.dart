import 'package:esdcustomer/config/app_theme.dart';
import 'package:esdcustomer/module/controller/order_controller.dart';
import 'package:esdcustomer/module/view/orders/order_detail_screen.dart';
import 'package:esdcustomer/widgets/bill_card.dart';
import 'package:esdcustomer/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({Key? key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final ctrl = Get.find<OrderController>();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
        ctrl.loadMore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Bills')),
      body: RefreshIndicator(
        onRefresh: () => ctrl.fetchOrders(),
        child: Obx(() {
          if (ctrl.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (ctrl.orders.isEmpty) {
            return ListView(
              children: const [
                SizedBox(height: 120),
                EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'No bills yet',
                  subtitle: 'Your purchase bills will show up here once you place an order with us.',
                ),
              ],
            );
          }
          return ListView.separated(
            controller: _scroll,
            padding: const EdgeInsets.all(16),
            itemCount: ctrl.orders.length + (ctrl.hasMore.value ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index >= ctrl.orders.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2.4)),
                );
              }
              final o = ctrl.orders[index];
              return BillCard(order: o, onTap: () => Get.to(() => OrderDetailScreen(orderId: o.id)));
            },
          );
        }),
      ),
    );
  }
}
