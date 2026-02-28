import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:daraz_task/home_screen/controller/home_page_controller.dart';
import 'package:daraz_task/home_screen/widgets/product_card.dart';
import 'package:daraz_task/constant/color/const_colour.dart';

class ProductGridForTab extends StatelessWidget {
  final int tabIndex;
  final HomePageController controller;

  const ProductGridForTab({
    super.key,
    required this.tabIndex,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final products = controller.productsForTab(tabIndex);

      if (products.isEmpty) {
        return SizedBox(
          height: 300,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.inbox_outlined, size: 48, color: ConstColour.textLight),
                const SizedBox(height: 12),
                Text(
                  controller.isLoadingProducts.value ? 'Loading...' : 'No products found',
                  style: const TextStyle(color: ConstColour.textMedium, fontSize: 14),
                ),
              ],
            ),
          ),
        );
      }

      return GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.68,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return ProductCard(product: products[index]);
        },
      );
    });
  }
}
