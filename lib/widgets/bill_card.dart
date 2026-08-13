import 'package:esdcustomer/config/app_theme.dart';
import 'package:esdcustomer/constants/app_color.dart';
import 'package:esdcustomer/constants/size.dart';
import 'package:esdcustomer/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class BillCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const BillCard({Key? key, required this.order, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusColor = AppTheme.statusColor(order.billingStatus);
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.receipt_long_rounded, color: AppTheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${order.orderNo ?? order.id}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    order.orderDate ?? '',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12.5),
                  ),
                  ...order.items.map((item) => Container(
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
                              Text(item.productName!, style: GoogleFonts.jost(fontSize: getTextSize(11), color: kLightText)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(currency.format(order.gTotal), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.billingStatus.toUpperCase(),
                    style: TextStyle(color: statusColor, fontSize: 10.5, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
