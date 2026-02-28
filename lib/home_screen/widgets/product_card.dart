import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:daraz_task/constant/color/const_colour.dart';
import 'package:daraz_task/models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Product Image ──────────────────────────────────────────
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xFFF9F9F9),
                    padding: const EdgeInsets.all(16),
                    child: CachedNetworkImage(
                      imageUrl: product.image,
                      fit: BoxFit.contain,
                      placeholder: (_, __) => const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: ConstColour.primary,
                          ),
                        ),
                      ),
                      errorWidget: (_, __, ___) => const Icon(
                        Icons.image_not_supported_outlined,
                        color: ConstColour.textLight,
                        size: 32,
                      ),
                    ),
                  ),
                ),
                // Favorite button
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.favorite_border, size: 16, color: ConstColour.textMedium),
                  ),
                ),
              ],
            ),
          ),
          // ── Product Info ───────────────────────────────────────────
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: ConstColour.textDark,
                      height: 1.3,
                    ),
                  ),
                  const Spacer(),
                  // Rating row
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 13, color: ConstColour.starColor),
                      const SizedBox(width: 2),
                      Text(
                        product.rating.rate.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 11,
                          color: ConstColour.textMedium,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '(${product.rating.count})',
                        style: const TextStyle(
                          fontSize: 10,
                          color: ConstColour.textLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Price row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: ConstColour.primary,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: ConstColour.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
