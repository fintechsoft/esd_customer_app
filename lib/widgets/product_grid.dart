import 'package:cached_network_image/cached_network_image.dart';
import 'package:esdcustomer/config/app_theme.dart';
import 'package:esdcustomer/models/product_model.dart';
import 'package:esdcustomer/module/view/products/product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ProductGrid extends StatelessWidget {
  final List<ProductModel> products;
  const ProductGrid({Key? key, required this.products}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final p = products[index];
        return InkWell(
          onTap: () => Get.to(() => ProductDetailScreen(productId: p.id)),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withOpacity(0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: p.img != null && p.img!.isNotEmpty
                        ? CachedNetworkImage(
                      imageUrl: p.img!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorWidget: (_, __, ___) => _placeholderImg(),
                    )
                        : _placeholderImg(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, height: 1.25),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              p.cost > 0 ? currency.format(p.cost) : 'Ask for price',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!p.inStock)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.danger.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('Out of stock', style: TextStyle(fontSize: 8.5, color: AppTheme.danger, fontWeight: FontWeight.w600)),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _placeholderImg() {
    return Container(
      color: AppTheme.bg,
      alignment: Alignment.center,
      child: Icon(Icons.image_outlined, color: AppTheme.textMuted.withOpacity(0.4), size: 32),
    );
  }
}