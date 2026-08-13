import 'package:esdcustomer/constants/app_color.dart';
import 'package:esdcustomer/constants/size.dart';
import 'package:esdcustomer/module/controller/auth_controller.dart';
import 'package:esdcustomer/module/controller/order_controller.dart';
import 'package:esdcustomer/module/controller/support_controller.dart';
import 'package:esdcustomer/module/view/orders/order_detail_screen.dart';
import 'package:esdcustomer/module/view/orders/orders_screen.dart';
import 'package:esdcustomer/module/view/products/products_screen.dart';
import 'package:esdcustomer/module/view/support/support_add_screen.dart';
import 'package:esdcustomer/module/view/support/support_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final orderCtrl = Get.find<OrderController>();
    final supportCtrl = Get.find<SupportController>();

    return Scaffold(
      backgroundColor: kAppBgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(auth),
            Expanded(
              child: RefreshIndicator(
                color: kPrimary,
                onRefresh: () async {
                  await Future.wait([orderCtrl.fetchOrders(), supportCtrl.fetchTickets()]);
                },
                child: Obx(() {
                  final orders = orderCtrl.orders;
                  final tickets = supportCtrl.tickets;
                  final totalSpent = orders.fold<double>(0, (sum, o) => sum + o.gTotal);
                  final pendingCount = orders.where((o) => o.billingStatus.toLowerCase() == 'pending').length;
                  final openTickets = tickets.where((t) => t.status.toLowerCase() != 'closed' && t.status.toLowerCase() != 'resolved').length;

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    children: [
                      _sectionLabel("Account summary"),
                      getVerticalSpace(10),
                      _buildStatsGrid(
                        totalOrders: orders.length,
                        pending: pendingCount,
                        totalSpent: totalSpent,
                        openTickets: openTickets,
                      ),
                      getVerticalSpace(20),
                      _buildQuickActions(),
                      getVerticalSpace(20),
                      _buildRecentBills(orderCtrl),
                      getVerticalSpace(4),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────
  Widget _buildHeader(AuthController auth) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Obx(() {
        final name = auth.customer.value?.name ?? 'Customer';
        final initials = _getInitials(name);
        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: GoogleFonts.jost(
                      fontSize: getTextSize(13),
                      color: kLightText,
                    ),
                  ),
                  getVerticalSpace(2),
                  Text(
                    name,
                    style: GoogleFonts.jost(
                      fontSize: getTextSize(18),
                      fontWeight: FontWeight.w700,
                      color: kDark,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            getHorizontalSpace(12),

            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: kAppBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                color: kLightText,
                size: 20,
              ),
            ),

            getHorizontalSpace(12),

            CircleAvatar(
              radius: 22,
              backgroundColor: kPrimaryTint,
              child: Text(
                initials,
                style: GoogleFonts.jost(
                  fontSize: getTextSize(14),
                  fontWeight: FontWeight.w700,
                  color: kPrimary,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.jost(fontSize: getTextSize(11), fontWeight: FontWeight.w600, color: kLightText, letterSpacing: 0.8),
    );
  }

  // ─── Stats grid ─────────────────────────────────────────────────────────
  Widget _buildStatsGrid({
    required int totalOrders,
    required int pending,
    required double totalSpent,
    required int openTickets,
  }) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      childAspectRatio: 1.55,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _statCard(
          icon: Icons.receipt_long_outlined,
          iconBg: kPrimaryTint,
          iconColor: kPrimary,
          value: '$totalOrders',
          label: 'Total orders',
        ),
        _statCard(
          icon: Icons.hourglass_bottom_rounded,
          iconBg: kWarningTint,
          iconColor: kWarning,
          value: '$pending',
          label: 'Pending bills',
        ),
        _statCard(
          icon: Icons.currency_rupee_rounded,
          iconBg: kAccentTint,
          iconColor: const Color(0xFFB4770A),
          value: currency.format(totalSpent),
          label: 'Total spent',
          valueFontSize: 14,
        ),
        _statCard(
          icon: Icons.support_agent_rounded,
          iconBg: kSuccessTint,
          iconColor: kSuccess,
          value: '$openTickets',
          label: 'Open requests',
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String value,
    required String label,
    double valueFontSize = 18,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.jost(fontSize: getTextSize(valueFontSize), fontWeight: FontWeight.w700, color: kDark, height: 1.1),
          ),
          getVerticalSpace(2),
          Text(label, style: GoogleFonts.jost(fontSize: getTextSize(11), color: kLightText)),
        ],
      ),
    );
  }

  // ─── Quick actions ──────────────────────────────────────────────────────
  Widget _buildQuickActions() {
    final actions = [
      {'label': 'My Bills', 'icon': Icons.receipt_long_outlined, 'bg': kPrimaryTint, 'color': kPrimary, 'onTap': () => Get.to(() => const OrdersScreen())},
      {'label': 'Products', 'icon': Icons.storefront_outlined, 'bg': kAccentTint, 'color': const Color(0xFFB4770A), 'onTap': () => Get.to(() => const ProductsScreen())},
      {'label': 'Support', 'icon': Icons.support_agent_outlined, 'bg': kSuccessTint, 'color': kSuccess, 'onTap': () => Get.to(() => const SupportAddScreen())},
      {'label': 'My Requests', 'icon': Icons.forum_outlined, 'bg': const Color(0xFFEEEDFE), 'color': const Color(0xFF534AB7), 'onTap': () => Get.to(() => const SupportScreen())},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
            child: Text('Quick actions', style: GoogleFonts.jost(fontSize: getTextSize(14), fontWeight: FontWeight.w600, color: kDark)),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: actions.map((action) {
                return GestureDetector(
                  onTap: action['onTap'] as VoidCallback,
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(color: action['bg'] as Color, borderRadius: BorderRadius.circular(14)),
                        child: Icon(action['icon'] as IconData, color: action['color'] as Color, size: 24),
                      ),
                      getVerticalSpace(6),
                      SizedBox(
                        width: 65,
                        child: Text(
                          action['label'] as String,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.jost(fontSize: getTextSize(10), color: kDark, height: 1.2),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Recent bills ───────────────────────────────────────────────────────
  Widget _buildRecentBills(OrderController orderCtrl) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder, width: 0.5),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent bills', style: GoogleFonts.jost(fontSize: getTextSize(14), fontWeight: FontWeight.w600, color: kDark)),
                GestureDetector(
                  onTap: () => Get.to(() => const OrdersScreen()),
                  child: Text('See all', style: GoogleFonts.jost(fontSize: getTextSize(13), color: kPrimary, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: kBorder),
          if (orderCtrl.isLoading.value)
            const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()))
          else if (orderCtrl.orders.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text('No bills yet', style: GoogleFonts.jost(fontSize: getTextSize(13), color: kLightText)),
            )
          else
            ...orderCtrl.orders.take(3).toList().asMap().entries.map((entry) {
              final i = entry.key;
              final order = entry.value;
              final sc = statusColors(order.billingStatus);
              return Column(
                children: [
                  InkWell(
                    onTap: () => Get.to(() => OrderDetailScreen(orderId: order.id)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(color: kPrimaryTint, borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.receipt_long_rounded, color: kPrimary, size: 18),
                          ),
                          getHorizontalSpace(10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Order #${order.orderNo ?? order.id}',
                                    style: GoogleFonts.jost(fontSize: getTextSize(13), fontWeight: FontWeight.w600, color: kDark)),
                                getVerticalSpace(2),
                                Text(order.orderDate ?? '', style: GoogleFonts.jost(fontSize: getTextSize(11), color: kLightText)),
                                getVerticalSpace(2),
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
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(currency.format(order.gTotal),
                                  style: GoogleFonts.jost(fontSize: getTextSize(13), fontWeight: FontWeight.w600, color: kDark)),
                              getVerticalSpace(3),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: sc['bg'], borderRadius: BorderRadius.circular(5)),
                                child: Text(order.billingStatus.toUpperCase(),
                                    style: GoogleFonts.jost(fontSize: getTextSize(9.5), fontWeight: FontWeight.w600, color: sc['text'])),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (i < orderCtrl.orders.take(3).length - 1) Divider(height: 1, color: kBorder),
                ],
              );
            }),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase() : 'C';
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning 👋';
    if (hour < 17) return 'Good afternoon 👋';
    return 'Good evening 👋';
  }
}
