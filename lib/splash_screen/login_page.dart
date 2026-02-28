import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:daraz_task/constant/color/const_colour.dart';
import 'package:daraz_task/splash_screen/controller/login_controller.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstColour.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: ConstColour.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.shopping_bag, color: Colors.white, size: 44),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Daraz',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: ConstColour.primary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Sign in to continue shopping',
                        style: TextStyle(
                          fontSize: 14,
                          color: ConstColour.textMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                // Username Field
                const Text(
                  'Username',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: ConstColour.textDark,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: controller.usernameController,
                  decoration: _inputDecoration('Enter username', Icons.person_outline),
                  validator: (v) => (v == null || v.isEmpty) ? 'Username is required' : null,
                ),
                const SizedBox(height: 20),
                // Password Field
                const Text(
                  'Password',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: ConstColour.textDark,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => TextFormField(
                    controller: controller.passwordController,
                    obscureText: controller.obscurePassword.value,
                    decoration: _inputDecoration('Enter password', Icons.lock_outline).copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.obscurePassword.value
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: ConstColour.textMedium,
                        ),
                        onPressed: controller.toggleObscure,
                      ),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Password is required' : null,
                  ),
                ),
                const SizedBox(height: 8),
                // Error message
                Obx(
                  () => controller.errorMessage.value.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            controller.errorMessage.value,
                            style: const TextStyle(color: Colors.red, fontSize: 13),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 12),
                // Hint
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ConstColour.shadowBlue20,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: ConstColour.shadowBlue40),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: ConstColour.shadowBlue, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Demo: username: johnd  |  password: m38rmF\$',
                          style: TextStyle(
                            fontSize: 12,
                            color: ConstColour.shadowBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Login Button
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value ? null : controller.login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ConstColour.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: ConstColour.primary.withOpacity(0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Sign In',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: ConstColour.textLight),
      prefixIcon: Icon(icon, color: ConstColour.textMedium, size: 20),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: ConstColour.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: ConstColour.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: ConstColour.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }
}
