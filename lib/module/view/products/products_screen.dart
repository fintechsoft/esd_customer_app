import 'package:esdcustomer/config/app_theme.dart';
import 'package:esdcustomer/models/category_model.dart';
import 'package:esdcustomer/module/controller/product_controller.dart';
import 'package:esdcustomer/module/view/products/category_products_screen.dart';
import 'package:esdcustomer/utils/category_icons.dart';
import 'package:esdcustomer/widgets/empty_state.dart';
import 'package:esdcustomer/widgets/product_grid.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ctrl = Get.find<ProductController>();
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchCtrl.clear();
    ctrl.clearSearch();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              onSubmitted: ctrl.search,
              onChanged: (v) => setState(() {}), // toggles clear (x) button visibility
              decoration: InputDecoration(
                hintText: 'Search ACs, TVs, appliances…',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.close_rounded), onPressed: _clearSearch)
                    : null,
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              // Actively searching — show flat results across all categories.
              if (ctrl.searchText.value.isNotEmpty) {
                return RefreshIndicator(
                  onRefresh: () => ctrl.fetchProducts(),
                  child: ctrl.isLoading.value
                      ? const Center(child: CircularProgressIndicator())
                      : ctrl.products.isEmpty
                      ? ListView(
                    children: const [
                      SizedBox(height: 100),
                      EmptyState(icon: Icons.search_off_rounded, title: 'No products found'),
                    ],
                  )
                      : ProductGrid(products: ctrl.products),
                );
              }

              // Default state — browse by category.
              return RefreshIndicator(
                onRefresh: ctrl.fetchCategories,
                child: ctrl.isLoadingCategories.value
                    ? const Center(child: CircularProgressIndicator())
                    : ctrl.categories.isEmpty
                    ? ListView(
                  children: const [
                    SizedBox(height: 100),
                    EmptyState(icon: Icons.storefront_outlined, title: 'No categories available'),
                  ],
                )
                    : _categoryGrid(ctrl.categories),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _categoryGrid(List<CategoryModel> categories) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.10,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final c = categories[index];
        return InkWell(
          onTap: () => Get.to(() => CategoryProductsScreen(categoryId: c.id, categoryName: c.name)),
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
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Icon(iconForCategory(c.name), color: AppTheme.primary, size: 20),
                ),
                const SizedBox(height: 5),
                Text(
                  c.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, height: 1.2),
                ),
                const SizedBox(height: 3),
                Text('${c.productCount} products', style: TextStyle(fontSize: 8, color: AppTheme.textMuted)),
              ],
            ),
          ),
        );
      },
    );
  }
}