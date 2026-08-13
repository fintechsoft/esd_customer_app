import 'dart:io';

import 'package:esdcustomer/config/app_theme.dart';
import 'package:esdcustomer/models/order_model.dart';
import 'package:esdcustomer/module/controller/order_controller.dart';
import 'package:esdcustomer/module/controller/support_controller.dart';
import 'package:esdcustomer/module/view/products/products_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class SupportAddScreen extends StatefulWidget {
  const SupportAddScreen({Key? key}) : super(key: key);

  @override
  State<SupportAddScreen> createState() => _SupportAddScreenState();
}

class _SupportAddScreenState extends State<SupportAddScreen> {
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  final _category = 'Product Issue'.obs;
  final _attachment = Rxn<File>();
  final _selectedOrder = Rxn<OrderModel>();
  final _selectedItem = Rxn<OrderItemModel>();

  final _categories = const ['Product Issue', 'Installation', 'Billing', 'Delivery', 'Other'];
  final supportCtrl = Get.find<SupportController>();
  final orderCtrl = Get.find<OrderController>();

  @override
  void initState() {
    super.initState();
    // Orders are usually already loaded (Home/Bills screens fetch them),
    // but make sure this screen doesn't show a false "no orders" state
    // if it's opened first thing after login.
    if (orderCtrl.orders.isEmpty && !orderCtrl.isLoading.value) {
      orderCtrl.fetchOrders();
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) _attachment.value = File(picked.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Raise Support Request')),
      body: Obx(() {
        if (orderCtrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // No order on file — nothing to link the ticket to, so don't allow raising one.
        if (orderCtrl.orders.isEmpty) {
          return _noOrdersState();
        }

        return _form();
      }),
    );
  }

  Widget _noOrdersState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_outlined, size: 56, color: AppTheme.textMuted.withOpacity(0.4)),
            const SizedBox(height: 16),
            const Text('No orders found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(
              'Support requests need to be linked to a previous order. Once you\'ve placed an order with us, you\'ll be able to raise a request here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Get.to(() => const ProductsScreen()),
              child: const Text('Browse Products'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _form() {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Which order is this about?', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Obx(() => DropdownButtonFormField<OrderModel>(
          value: _selectedOrder.value,
          isExpanded: true,
          decoration: const InputDecoration(hintText: 'Select an order'),
          items: orderCtrl.orders.map((o) {
            return DropdownMenuItem(
              value: o,
              child: Text(
                'Order #${o.orderNo ?? o.id} · ${o.orderDate ?? ''} · ${currency.format(o.gTotal)}',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13.5),
              ),
            );
          }).toList(),
          onChanged: (val) {
            _selectedOrder.value = val;
            _selectedItem.value = null; // Reset selected item
          },
          validator: (val) => val == null ? 'Please select an order' : null,
        )),
        const SizedBox(height: 18),
        Obx(() {
          final order = _selectedOrder.value;

          if (order == null) {
            return const SizedBox();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Product',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<OrderItemModel>(
                value: _selectedItem.value,
                isExpanded: true,
                decoration: const InputDecoration(
                  hintText: 'Select Product',
                ),
                items: order.items.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(
                      '${item.productName ?? "Unknown"}'
                          ' (${item.productCode ?? ""})'
                          ' x${item.qty}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (item) {
                  _selectedItem.value = item;
                },
                validator: (value) =>
                value == null ? 'Please select a product' : null,
              ),
              const SizedBox(height: 18),
            ],
          );
        }),
        const SizedBox(height: 18),
        const Text('Category', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((c) {
            final selected = _category.value == c;
            return ChoiceChip(
              label: Text(c, style: TextStyle(fontSize: 12.5, color: selected ? Colors.white : AppTheme.textDark)),
              selected: selected,
              selectedColor: AppTheme.primary,
              backgroundColor: Colors.white,
              onSelected: (_) => _category.value = c,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: selected ? AppTheme.primary : Colors.black12),
              ),
            );
          }).toList(),
        )),
        const SizedBox(height: 18),
        const Text('Subject', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(controller: _subjectCtrl, decoration: const InputDecoration(hintText: 'Briefly describe the issue')),
        const SizedBox(height: 18),
        const Text('Message', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: _messageCtrl,
          maxLines: 5,
          decoration: const InputDecoration(hintText: 'Explain in detail what happened...'),
        ),
        const SizedBox(height: 18),
        Obx(() => _attachment.value == null
            ? OutlinedButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.attach_file_rounded, size: 18),
          label: const Text('Attach a photo (optional)'),
        )
            : Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(_attachment.value!, width: 56, height: 56, fit: BoxFit.cover),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(_attachment.value!.path.split('/').last, overflow: TextOverflow.ellipsis)),
            IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => _attachment.value = null,
            ),
          ],
        )),
        const SizedBox(height: 26),
        Obx(() => SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: supportCtrl.isSubmitting.value ? null : _submit,
            child: supportCtrl.isSubmitting.value
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4))
                : const Text('Submit Request'),
          ),
        )),
      ],
    );
  }

  Future<void> _submit() async {
    if (_selectedOrder.value == null) {
      Get.snackbar('Order required', 'Please select which order this request is about',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (_subjectCtrl.text.trim().isEmpty || _messageCtrl.text.trim().isEmpty) {
      Get.snackbar('Missing details', 'Please fill in subject and message',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (_selectedItem.value == null) {
      Get.snackbar(
        'Product required',
        'Please select the product you are facing an issue with',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    final ok = await supportCtrl.raiseTicket(
      subject: _subjectCtrl.text.trim(),
      message: _messageCtrl.text.trim(),
      category: _category.value,
      orderId: _selectedOrder.value!.id,
      attachment: _attachment.value,
    );
    if (ok && mounted) Get.back();
  }
}