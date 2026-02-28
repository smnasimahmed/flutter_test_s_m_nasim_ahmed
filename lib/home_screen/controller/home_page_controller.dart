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

  late TabController tabController;

  final ScrollController scrollController = ScrollController();

  final RxList<ProductModel> allProducts = <ProductModel>[].obs;
  final RxMap<String, List<ProductModel>> categoryProducts =
      <String, List<ProductModel>>{}.obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxList<String> tabLabels = <String>['All'].obs;

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

  Future<void> fetchAll() async {
    isLoadingProducts.value = true;
    await Future.wait([
      fetchProducts(),
      fetchCategories(),
      fetchUserProfile(),
    ]);
    isLoadingProducts.value = false;
  }

  Future<void> onRefresh() async {
    isRefreshing.value = true;
    allProducts.clear();
    categoryProducts.clear();
    await fetchAll();
    isRefreshing.value = false;
  }

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

  Future<void> fetchCategories() async {
    try {
      final response = await ApiService.get(
        ApiEndPoint.baseUrl + ApiEndPoint.categories,
      );
      if (response.isSuccess && response.data is List) {
        final cats = (response.data as List).map((e) => e.toString()).toList();

        final tabs = ['All', ...cats.take(3)];

        final prevIndex = tabController.index.clamp(0, tabs.length - 1);

        final oldController = tabController;
        tabController = TabController(
          length: tabs.length,
          vsync: this,
          initialIndex: prevIndex,
        );
        oldController.dispose();

        tabLabels.value = tabs;

        await Future.wait(cats.take(3).map(fetchProductsByCategory));
      }
    } catch (e) {
      errorLog(e, source: 'fetchCategories');
    }
  }

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

  List<ProductModel> productsForTab(int tabIndex) {
    if (tabIndex == 0) return allProducts;
    if (tabIndex >= tabLabels.length) return [];
    final cat = tabLabels[tabIndex];
    return categoryProducts[cat] ?? [];
  }

  Future<void> logout() async {
    await AppStorage().clearAll();
    Get.offAllNamed('/loginPage');
  }
}
