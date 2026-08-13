import 'package:esdcustomer/constants/app_color.dart';
import 'package:esdcustomer/models/address_model.dart';
import 'package:esdcustomer/module/controller/address_controller.dart';
import 'package:esdcustomer/module/view/profile/address_add_screen.dart';
import 'package:esdcustomer/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AddressController>();

    return Scaffold(
      backgroundColor: kAppBgColor,
      appBar: AppBar(title: const Text('Saved Addresses')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const AddressAddScreen()),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Address'),
      ),
      body: RefreshIndicator(
        onRefresh: ctrl.fetchAddresses,
        child: Obx(() {
          if (ctrl.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (ctrl.addresses.isEmpty) {
            return ListView(
              children: const [
                SizedBox(height: 100),
                EmptyState(
                  icon: Icons.location_on_outlined,
                  title: 'No saved addresses',
                  subtitle: 'Add a billing, shipping, or installation address to speed up future orders.',
                ),
              ],
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            itemCount: ctrl.addresses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final a = ctrl.addresses[index];
              return _addressCard(context, ctrl, a);
            },
          );
        }),
      ),
    );
  }

  Widget _addressCard(BuildContext context, AddressController ctrl, AddressModel a) {
    final typeColor = a.addressType == 'billing'
        ? kPrimary
        : a.addressType == 'installation'
        ? kAccent
        : kSuccess;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: typeColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.location_on_rounded, color: typeColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: typeColor.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                  child: Text(a.label.toUpperCase(),
                      style: TextStyle(color: typeColor, fontSize: 10, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 8),
                Text(a.fullAddress, style: const TextStyle(fontSize: 13.5, height: 1.4)),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: kGreyIcon, size: 20),
            onSelected: (value) {
              if (value == 'edit') {
                Get.to(() => AddressAddScreen(existing: a));
              } else if (value == 'delete') {
                _confirmDelete(context, ctrl, a.id);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AddressController ctrl, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Address'),
        content: const Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ctrl.deleteAddress(id);
            },
            child: Text('Delete', style: TextStyle(color: kDanger)),
          ),
        ],
      ),
    );
  }
}