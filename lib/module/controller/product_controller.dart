import 'package:esdcustomer/config/api_constants.dart';
import 'package:esdcustomer/models/category_model.dart';
import 'package:esdcustomer/models/product_model.dart';
import 'package:esdcustomer/services/api_service.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

class ProductController extends GetxController {
  final products = <ProductModel>[].obs;
  final categories = <CategoryModel>[].obs;
  final isLoading = false.obs;
  final isLoadingCategories = false.obs;
  final searchText = ''.obs;
  final selectedCategory = ''.obs; // empty = all

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    isLoadingCategories.value = true;
    try {
      final res = await ApiService.instance.get(ApiConstants.productCategories);
      final data = Map<String, dynamic>.from(res['data'] ?? {});
      categories.value = (data['categories'] as List<dynamic>? ?? [])
          .map((e) => CategoryModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on ApiException catch (e) {
      EasyLoading.showError(e.message);
    } finally {
      isLoadingCategories.value = false;
    }
  }

  Future<void> fetchProducts() async {
    isLoading.value = true;
    try {
      // Matches CustomerProductController::index() — GET with q/category query params.
      final query = <String, dynamic>{};
      if (searchText.value.isNotEmpty) query['q'] = searchText.value;
      if (selectedCategory.value.isNotEmpty) query['category'] = selectedCategory.value;

      final res = await ApiService.instance.get(ApiConstants.products, query: query);
      final data = Map<String, dynamic>.from(res['data'] ?? {});
      products.value = (data['products'] as List<dynamic>? ?? [])
          .map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } on ApiException catch (e) {
      EasyLoading.showError(e.message);
    } finally {
      isLoading.value = false;
    }
  }

  /// Search across ALL categories — clears any category filter so results
  /// aren't silently scoped to whatever category was last browsed.
  void search(String q) {
    searchText.value = q;
    selectedCategory.value = '';
    fetchProducts();
  }

  void clearSearch() {
    searchText.value = '';
    products.clear();
  }

  void filterByCategory(String categoryId) {
    selectedCategory.value = categoryId;
    searchText.value = '';
    fetchProducts();
  }
}