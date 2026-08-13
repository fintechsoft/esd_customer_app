import 'package:esdcustomer/config/app_theme.dart';
import 'package:esdcustomer/module/controller/auth_controller.dart';
import 'package:esdcustomer/module/controller/product_detail_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ProductDetailScreen extends StatelessWidget {
  final int productId;
  const ProductDetailScreen({Key? key, required this.productId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(ProductDetailController(productId), tag: 'product_$productId');
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final p = ctrl.product.value;
        if (p == null) return const Center(child: Text('Product not found'));

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: AspectRatio(
                aspectRatio: 1.3,
                child: p.img != null && p.img!.isNotEmpty
                    ? CachedNetworkImage(imageUrl: p.img!, fit: BoxFit.cover)
                    : Container(
                  color: AppTheme.bg,
                  alignment: Alignment.center,
                  child: Icon(Icons.image_outlined, size: 48, color: AppTheme.textMuted.withOpacity(0.4)),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(p.name, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, height: 1.3)),
            const SizedBox(height: 8),
            Text(
              p.cost > 0 ? currency.format(p.cost) : 'Contact us for price',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.primary),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (p.code != null && p.code!.isNotEmpty) _tag('Model: ${p.code}'),
                if (p.color != null && p.color!.isNotEmpty) _tag('Color: ${p.color}'),
                if (p.warranty != null && p.warranty! > 0) _tag('Warranty: ${p.warranty} mo'),
              ],
            ),
            if (p.details != null && p.details!.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text('Description', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 8),
              Text(p.details!, style: TextStyle(color: AppTheme.textMuted, fontSize: 13.5, height: 1.5)),
            ],
            const SizedBox(height: 26),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showEnquirySheet(context, ctrl),
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                label: const Text('Enquire Now'),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: AppTheme.bg, borderRadius: BorderRadius.circular(10)),
      child: Text(text, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
    );
  }

  void _showEnquirySheet(BuildContext context, ProductDetailController ctrl) {
    final auth = Get.find<AuthController>();
    final p = ctrl.product.value;
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    final nameCtrl = TextEditingController(text: auth.customer.value?.name ?? '');
    final phoneCtrl = TextEditingController(text: auth.customer.value?.phone ?? '');
    final msgCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Send an Enquiry', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  "You're enquiring about:",
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12.5),
                ),
                const SizedBox(height: 10),

                // Enquired product — shown so the customer confirms what
                // they're actually asking about before sending.
                if (p != null)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.bg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black.withOpacity(0.05)),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 48,
                            height: 48,
                            child: p.img != null && p.img!.isNotEmpty
                                ? CachedNetworkImage(imageUrl: p.img!, fit: BoxFit.cover)
                                : Container(
                              color: Colors.white,
                              alignment: Alignment.center,
                              child: Icon(Icons.image_outlined, size: 20, color: AppTheme.textMuted.withOpacity(0.4)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, height: 1.25),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                p.cost > 0 ? currency.format(p.cost) : 'Ask for price',
                                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppTheme.primary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 18),

                // Name/phone are locked to the logged-in customer's account —
                // not editable, so support always contacts the right person.
                _lockedField('Your name', nameCtrl),
                const SizedBox(height: 12),
                _lockedField('Phone number', phoneCtrl),
                const SizedBox(height: 12),

                TextField(
                  controller: msgCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(hintText: 'Any specific question?'),
                ),
                const SizedBox(height: 16),
                Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: ctrl.isSubmittingEnquiry.value
                        ? null
                        : () async {
                      if (msgCtrl.text.trim().isEmpty) {
                        Get.snackbar('Add a message', 'Let us know what you\'d like to ask',
                            snackPosition: SnackPosition.BOTTOM);
                        return;
                      }
                      await ctrl.sendEnquiry(
                        message: msgCtrl.text.trim(),
                      );
                      if (context.mounted) Navigator.pop(ctx);
                    },
                    child: ctrl.isSubmittingEnquiry.value
                        ? const SizedBox(
                        width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2))
                        : const Text('Send Enquiry'),
                  ),
                )),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _lockedField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      enabled: false,
      style: const TextStyle(color: AppTheme.textDark),
      decoration: InputDecoration(
        hintText: label,
        filled: true,
        fillColor: AppTheme.bg,
        suffixIcon: Icon(Icons.lock_outline_rounded, size: 16, color: AppTheme.textMuted.withOpacity(0.6)),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.black.withOpacity(0.06)),
        ),
      ),
    );
  }
}