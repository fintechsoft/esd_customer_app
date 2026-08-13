import 'package:esdcustomer/constants/app_color.dart';
import 'package:esdcustomer/models/enquiry_model.dart';
import 'package:esdcustomer/module/controller/enquiry_controller.dart';
import 'package:esdcustomer/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyEnquiresScreen extends StatelessWidget {
  const MyEnquiresScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<EnquiryController>();

    return Scaffold(
      backgroundColor: kAppBgColor,
      appBar: AppBar(title: const Text('My Enquiries')),
      body: RefreshIndicator(
        onRefresh: ctrl.fetchEnquiries,
        child: Obx(() {
          if (ctrl.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (ctrl.enquiries.isEmpty) {
            return ListView(
              children: const [
                SizedBox(height: 100),
                EmptyState(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'No enquiries yet',
                  subtitle: 'Enquiries you send from a product page will show up here.',
                ),
              ],
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: ctrl.enquiries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _enquiryCard(ctrl.enquiries[index]),
          );
        }),
      ),
    );
  }

  Widget _enquiryCard(EnquiryModel e) {
    final statusColor = _statusColor(e.status);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(e.product,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                child: Text(e.status.toUpperCase(),
                    style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          if (e.remarks != null && e.remarks!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(e.remarks!, style: TextStyle(color: kLightText, fontSize: 12.5, height: 1.4)),
          ],
          const SizedBox(height: 8),
          Text(e.createdAt, style: TextStyle(color: kGreyIcon, fontSize: 11)),
        ],
      ),
    );
  }

  /// Lead statuses (New/Contacted/Qualified/Lost/Closed) are a different
  /// set from order/support statuses, so this maps independently rather
  /// than reusing statusColors() from app_color.dart.
  Color _statusColor(String status) {
    switch (status) {
      case 'Contacted':
        return kWarning;
      case 'Qualified':
        return kSuccess;
      case 'Lost':
        return kDanger;
      case 'Closed':
        return kLightText;
      case 'New':
      default:
        return kPrimary;
    }
  }
}