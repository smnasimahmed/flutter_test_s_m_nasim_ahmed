import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:daraz_task/constant/color/const_colour.dart';
import 'package:daraz_task/home_screen/controller/home_page_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomePageController>();

    return Scaffold(
      backgroundColor: ConstColour.background,
      appBar: AppBar(
        backgroundColor: ConstColour.primary,
        foregroundColor: Colors.white,
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.back();
                        controller.logout();
                      },
                      child: const Text('Logout', style: TextStyle(color: ConstColour.primary)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        final user = controller.currentUser.value;

        if (controller.isLoadingUser.value && user == null) {
          return const Center(
            child: CircularProgressIndicator(color: ConstColour.primary),
          );
        }

        if (user == null) {
          return const Center(child: Text('Could not load profile'));
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // ── Avatar Header ──────────────────────────────────────
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE2231A), Color(0xFFFF6B47)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: Colors.white,
                      child: Text(
                        user.fullName.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: ConstColour.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user.fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${user.username}',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              // ── Info Cards ─────────────────────────────────────────
              const SizedBox(height: 16),
              _infoSection('Personal Information', [
                _infoTile(Icons.person_outline, 'Full Name', user.fullName),
                _infoTile(Icons.alternate_email, 'Username', user.username),
                _infoTile(Icons.email_outlined, 'Email', user.email),
                _infoTile(Icons.phone_outlined, 'Phone', user.phone),
              ]),
              const SizedBox(height: 12),
              _infoSection('Address', [
                _infoTile(Icons.location_on_outlined, 'Address', user.address.fullAddress),
                _infoTile(Icons.location_city_outlined, 'City', user.address.city),
                _infoTile(Icons.local_post_office_outlined, 'Zipcode', user.address.zipcode),
              ]),
              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  Widget _infoSection(String title, List<Widget> tiles) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: ConstColour.textMedium,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const Divider(height: 1, color: ConstColour.divider),
          ...tiles,
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: ConstColour.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: ConstColour.textLight),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? '—' : value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: ConstColour.textDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
