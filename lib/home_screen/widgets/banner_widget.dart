import 'package:flutter/material.dart';
import 'package:daraz_task/constant/color/const_colour.dart';
import 'package:daraz_task/models/user_model.dart';

class BannerWidget extends StatelessWidget {
  final UserModel? user;

  const BannerWidget({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE2231A), Color(0xFFFF6B47)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top row: greeting + notifications
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user != null ? 'Hello, ${user!.name.firstname} 👋' : 'Hello, Shopper 👋',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'What are you looking for today?',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  // Cart & notification icons
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                    onPressed: () {},
                  ),
                  const SizedBox(
                    width: 30,
                  )
                ],
              ),
              const SizedBox(height: 12),
              // Search Bar
              Container(
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    SizedBox(width: 12),
                    Icon(Icons.search, color: ConstColour.textMedium, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Search for products, brands...',
                      style: TextStyle(color: ConstColour.textLight, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Promo chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _promoChip('🔥 Flash Sale', Colors.orangeAccent),
                    const SizedBox(width: 8),
                    _promoChip('🆕 New Arrivals', Colors.greenAccent),
                    const SizedBox(width: 8),
                    _promoChip('💎 Top Picks', Colors.purpleAccent),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _promoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.6)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
