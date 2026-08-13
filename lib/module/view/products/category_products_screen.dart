import 'package:esdcustomer/module/controller/product_controller.dart';
import 'package:esdcustomer/widgets/empty_state.dart';
import 'package:esdcustomer/widgets/product_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

class CategoryProductsScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  const CategoryProductsScreen({Key? key, required this.categoryId, required this.categoryName}) : super(key: key);

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  final ctrl = Get.find<ProductController>();

  @override
  void initState() {
    super.initState();
    // Deferred to after this build frame finishes — calling this
    // synchronously here mutates an Rx value while the tree (this screen's
    // own Obx, and possibly ProductsScreen still mid-transition beneath it)
    // is still being built, which GetX/Flutter don't allow.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      ctrl.filterByCategory(widget.categoryId.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.categoryName)),
      body: RefreshIndicator(
        onRefresh: () => ctrl.fetchProducts(),
        child: Obx(() {
          if (ctrl.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (ctrl.products.isEmpty) {
            return ListView(
              children: const [
                SizedBox(height: 100),
                EmptyState(icon: Icons.storefront_outlined, title: 'No products in this category yet'),
              ],
            );
          }
          return ProductGrid(products: ctrl.products);
        }),
      ),
    );
  }
}