import 'package:esdcustomer/config/api_constants.dart';
import 'package:esdcustomer/config/app_theme.dart';
import 'package:esdcustomer/models/order_model.dart';
import 'package:esdcustomer/module/controller/order_detail_controller.dart';
import 'package:esdcustomer/utils/pdf_launcher.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class OrderDetailScreen extends StatelessWidget {
  final int orderId;
  const OrderDetailScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(OrderDetailController(orderId), tag: 'order_$orderId');
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: const Text('Bill Details')),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final detail = ctrl.detail.value;
        if (detail == null) {
          return const Center(child: Text('Unable to load this bill'));
        }
        final order = detail.order;
        final statusColor = AppTheme.statusColor(order.billingStatus);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Order #${order.orderNo ?? order.id}',
                          style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(20)),
                        child: Text(order.billingStatus.toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(order.orderDate ?? '', style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12.5)),
                  const SizedBox(height: 18),
                  Text('Total Amount', style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 12.5)),
                  Text(currency.format(order.grandTotal),
                      style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final buttonWidth = (constraints.maxWidth - 12) / 2;

                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: buttonWidth,
                      child: _actionButton(
                        icon: Icons.file_present_rounded,
                        title: "Order Slip",
                        onTap: () => openPdf(ApiConstants.baseUrl+"/"+order.orderPdfLink!),
                      ),
                    ),

                    if (order.TallyBillLink != null &&
                        order.TallyBillLink!.isNotEmpty)
                      SizedBox(
                        width: buttonWidth,
                        child: _actionButton(
                          icon: Icons.picture_as_pdf_outlined,
                          title: "Download Bill",
                          onTap: () => openPdf(ApiConstants.baseUrl+"/"+order.TallyBillLink!),
                        ),
                      ),

                    if (order.deliverySlipLink != null &&
                        order.deliverySlipLink!.isNotEmpty)
                      SizedBox(
                        width: buttonWidth,
                        child: _actionButton(
                          icon: Icons.local_shipping_outlined,
                          title: "Delivery Slip",
                          onTap: () => openPdf(ApiConstants.baseUrl+"/"+order.deliverySlipLink!),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            if (detail.shippingAdd != null && detail.shippingAdd!.isNotEmpty) ...[
              const Text('Delivery Address', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 8),
              Text(detail.shippingAdd!, style: TextStyle(color: AppTheme.textMuted, fontSize: 13.5, height: 1.4)),
              const SizedBox(height: 20),
            ],
            const Text('Items', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 10),
            ...detail.items.map((item) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black.withOpacity(0.05)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.productName!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                            if (item.productCode != null) ...[
                              const SizedBox(height: 3),
                              Text('Code: ${item.productCode}', style: TextStyle(color: AppTheme.textMuted, fontSize: 11.5)),
                            ],

                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('x${item.qty}', style: TextStyle(color: AppTheme.textMuted, fontSize: 12.5)),
                          const SizedBox(height: 3),
                          Text(currency.format(item.price), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                        ],
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 12),
            if (detail.exchangeItems != null && detail.exchangeItems!.isNotEmpty)...[
            const Text('Exchange Items', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 10),
            ...detail.exchangeItems.map((item) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.black.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.productName!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('x${item.qty}', style: TextStyle(color: AppTheme.textMuted, fontSize: 12.5)),
                      const SizedBox(height: 3),
                      Text(currency.format(item.price), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                    ],
                  ),
                ],
              ),
            )),
            const SizedBox(height: 12),
],
            if (detail.payments != null && detail.payments!.isNotEmpty)...[
              const Text('Payment Details', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 10),
              ...detail.payments.map((item) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.black.withOpacity(0.05)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.modeName!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${item.details}', style: TextStyle(color: AppTheme.textMuted, fontSize: 12.5)),
                        const SizedBox(height: 3),
                        Text(currency.format(item.amount), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                      ],
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 12),
            ],

          ],
        );
      }),
    );
  }
  Widget buildActionButtons(OrderModel order) {
    final List<Widget> buttons = [];

    buttons.add(
      _actionButton(
        icon: Icons.file_present_rounded,
        title: 'Order Slip',
        onTap: () => openPdf(ApiConstants.baseUrl+"/"+order.orderPdfLink!),
      ),
    );

    if (order.TallyBillLink != null &&
        order.TallyBillLink!.trim().isNotEmpty) {
      buttons.add(
        _actionButton(
          icon: Icons.picture_as_pdf_outlined,
          title: 'Download Bill',
          onTap: () => openPdf(ApiConstants.baseUrl+"/"+order.TallyBillLink!),
        ),
      );
    }

    if (order.deliverySlipLink != null &&
        order.deliverySlipLink!.trim().isNotEmpty) {
      buttons.add(
        _actionButton(
          icon: Icons.local_shipping_outlined,
          title: 'Delivery Slip',
          onTap: () => openPdf(ApiConstants.baseUrl+"/"+order.deliverySlipLink!),
        ),
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: buttons,
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 170,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
