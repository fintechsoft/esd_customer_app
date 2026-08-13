// import 'package:esdcustomer/config/app_theme.dart';
// import 'package:esdcustomer/module/controller/support_controller.dart';
// import 'package:esdcustomer/module/view/support/support_add_screen.dart';
// import 'package:esdcustomer/widgets/empty_state.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// class SupportScreen extends StatelessWidget {
//   const SupportScreen({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final ctrl = Get.find<SupportController>();
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('Support')),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () => Get.to(() => const SupportAddScreen()),
//         backgroundColor: AppTheme.primary,
//         foregroundColor: Colors.white,
//         icon: const Icon(Icons.add_rounded),
//         label: const Text('Raise Request'),
//       ),
//       body: RefreshIndicator(
//         onRefresh: ctrl.fetchTickets,
//         child: Obx(() {
//           if (ctrl.isLoading.value) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (ctrl.tickets.isEmpty) {
//             return ListView(
//               children: const [
//                 SizedBox(height: 100),
//                 EmptyState(
//                   icon: Icons.support_agent_outlined,
//                   title: 'No support requests yet',
//                   subtitle: 'Facing an issue with a product or order? Raise a request and our team will get back to you.',
//                 ),
//               ],
//             );
//           }
//           return ListView.separated(
//             padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
//             itemCount: ctrl.tickets.length,
//             separatorBuilder: (_, __) => const SizedBox(height: 12),
//             itemBuilder: (context, index) {
//               final t = ctrl.tickets[index];
//               final statusColor = AppTheme.statusColor(t.status);
//               return Container(
//                 padding: const EdgeInsets.all(14),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(color: Colors.black.withOpacity(0.05)),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(t.ticketNo, style: TextStyle(color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
//                         Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
//                           decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
//                           child: Text(
//                             t.status.replaceAll('_', ' ').toUpperCase(),
//                             style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w700),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     Text(t.subject, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
//                     const SizedBox(height: 4),
//                     Text(t.message, maxLines: 2, overflow: TextOverflow.ellipsis,
//                         style: TextStyle(color: AppTheme.textMuted, fontSize: 12.5)),
//                     if (t.adminReply != null && t.adminReply!.isNotEmpty) ...[
//                       const SizedBox(height: 10),
//                       Container(
//                         padding: const EdgeInsets.all(10),
//                         decoration: BoxDecoration(color: AppTheme.bg, borderRadius: BorderRadius.circular(10)),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text('Support team reply', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
//                             const SizedBox(height: 4),
//                             Text(t.adminReply!, style: const TextStyle(fontSize: 12.5)),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               );
//             },
//           );
//         }),
//       ),
//     );
//   }
// }
import 'package:esdcustomer/config/app_theme.dart';
import 'package:esdcustomer/module/controller/support_controller.dart';
import 'package:esdcustomer/module/view/support/support_add_screen.dart';
import 'package:esdcustomer/module/view/support/support_ticket_detail_screen.dart';
import 'package:esdcustomer/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SupportController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Support')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const SupportAddScreen()),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Raise Request'),
      ),
      body: RefreshIndicator(
        onRefresh: ctrl.fetchTickets,
        child: Obx(() {
          if (ctrl.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (ctrl.tickets.isEmpty) {
            return ListView(
              children: const [
                SizedBox(height: 100),
                EmptyState(
                  icon: Icons.support_agent_outlined,
                  title: 'No support requests yet',
                  subtitle: 'Facing an issue with a product or order? Raise a request and our team will get back to you.',
                ),
              ],
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            itemCount: ctrl.tickets.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final t = ctrl.tickets[index];
              final statusColor = AppTheme.statusColor(t.status);
              return InkWell(
                onTap: () => Get.to(() => SupportTicketDetailScreen(ticketId: t.id)),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black.withOpacity(0.05)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(t.ticketNo, style: TextStyle(color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                            decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                            child: Text(
                              t.status.replaceAll('_', ' ').toUpperCase(),
                              style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(t.subject, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                      const SizedBox(height: 4),
                      Text(t.message, maxLines: 2, overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 12.5)),
                      if (t.adminReply != null && t.adminReply!.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: AppTheme.bg, borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Support team reply', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text(t.adminReply!, style: const TextStyle(fontSize: 12.5)),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('View conversation', style: TextStyle(color: AppTheme.primary, fontSize: 11.5, fontWeight: FontWeight.w600)),
                          Icon(Icons.chevron_right_rounded, size: 16, color: AppTheme.primary),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}