import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:daraz_task/constant/api/api_end_point.dart';
import 'package:daraz_task/models/product_model.dart';
import 'package:daraz_task/models/user_model.dart';
import 'package:daraz_task/services/api/api_service.dart';
import 'package:daraz_task/services/log/app_log.dart';
import 'package:daraz_task/services/log/error_log.dart';
import 'package:daraz_task/services/storage/storage_service.dart';

class HomePageController extends GetxController with GetTickerProviderStateMixin {
  // ─── Tab Controller ───────────────────────────────────────────────────
  // Owns the tab index. Shared between the TabBar and the PageView.
  // When categories load, we rebuild it with the correct length.
  late TabController tabController;

  // ─── Single Scroll Controller ─────────────────────────────────────────
  // The ONE vertical scroll owner. Passed to the outer CustomScrollView.
  // No child widget should create its own scroll context.
  final ScrollController scrollController = ScrollController();

  // ─── Observable data ──────────────────────────────────────────────────
  final RxList<ProductModel> allProducts = <ProductModel>[].obs;
  final RxMap<String, List<ProductModel>> categoryProducts =
      <String, List<ProductModel>>{}.obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxList<String> tabLabels = <String>['All'].obs;

  // ─── Loading states ───────────────────────────────────────────────────
  final RxBool isLoadingProducts = false.obs;
  final RxBool isLoadingUser = false.obs;
  final RxBool isRefreshing = false.obs;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 1, vsync: this);
    fetchAll();
  }

  @override
  void onClose() {
    tabController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  // ─── Fetch all data ───────────────────────────────────────────────────
  Future<void> fetchAll() async {
    isLoadingProducts.value = true;
    await Future.wait([
      fetchProducts(),
      fetchCategories(),
      fetchUserProfile(),
    ]);
    isLoadingProducts.value = false;
  }

  // ─── Pull-to-refresh ─────────────────────────────────────────────────
  Future<void> onRefresh() async {
    isRefreshing.value = true;
    allProducts.clear();
    categoryProducts.clear();
    await fetchAll();
    isRefreshing.value = false;
  }

  // ─── Fetch all products ───────────────────────────────────────────────
  Future<void> fetchProducts() async {
    try {
      final response = await ApiService.get(
        ApiEndPoint.baseUrl + ApiEndPoint.products,
      );
      if (response.isSuccess && response.data is List) {
        allProducts.value = (response.data as List)
            .map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        appLog('Products: ${allProducts.length}', source: 'HomePageController');
      }
    } catch (e) {
      errorLog(e, source: 'fetchProducts');
    }
  }

  // ─── Fetch categories → rebuild tab controller ────────────────────────
  Future<void> fetchCategories() async {
    try {
      final response = await ApiService.get(
        ApiEndPoint.baseUrl + ApiEndPoint.categories,
      );
      if (response.isSuccess && response.data is List) {
        final cats = (response.data as List).map((e) => e.toString()).toList();

        // Tabs: All + first 3 categories
        final tabs = ['All', ...cats.take(3)];

        // Save current index before rebuilding controller
        final prevIndex = tabController.index.clamp(0, tabs.length - 1);

        // Rebuild TabController with correct count
        final oldController = tabController;
        tabController = TabController(
          length: tabs.length,
          vsync: this,
          initialIndex: prevIndex,
        );
        oldController.dispose();

        // Update labels AFTER rebuilding controller
        tabLabels.value = tabs;

        // Fetch per-category products
        await Future.wait(cats.take(3).map(fetchProductsByCategory));
      }
    } catch (e) {
      errorLog(e, source: 'fetchCategories');
    }
  }

  // ─── Fetch products for one category ─────────────────────────────────
  Future<void> fetchProductsByCategory(String category) async {
    try {
      final response = await ApiService.get(
        '${ApiEndPoint.baseUrl}${ApiEndPoint.productsByCategory}/$category',
      );
      if (response.isSuccess && response.data is List) {
        categoryProducts[category] = (response.data as List)
            .map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        categoryProducts.refresh();
      }
    } catch (e) {
      errorLog(e, source: 'fetchProductsByCategory($category)');
    }
  }

  // ─── Fetch user profile ───────────────────────────────────────────────
  Future<void> fetchUserProfile() async {
    try {
      isLoadingUser.value = true;
      int userId = AppStorage().getUserId();
      if (userId == 0) userId = 1;
      final response = await ApiService.get(
        ApiEndPoint.baseUrl + ApiEndPoint.userProfile(userId),
      );
      if (response.isSuccess && response.data is Map) {
        currentUser.value = UserModel.fromJson(Map<String, dynamic>.from(response.data));
      }
    } catch (e) {
      errorLog(e, source: 'fetchUserProfile');
    } finally {
      isLoadingUser.value = false;
    }
  }

  // ─── Get products for a tab index ─────────────────────────────────────
  List<ProductModel> productsForTab(int tabIndex) {
    if (tabIndex == 0) return allProducts;
    if (tabIndex >= tabLabels.length) return [];
    final cat = tabLabels[tabIndex];
    return categoryProducts[cat] ?? [];
  }

  // ─── Logout ───────────────────────────────────────────────────────────
  Future<void> logout() async {
    await AppStorage().clearAll();
    Get.offAllNamed('/loginPage');
  }
}
