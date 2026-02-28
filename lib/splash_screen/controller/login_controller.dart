import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:daraz_task/constant/api/api_end_point.dart';
import 'package:daraz_task/routes/app_routes.dart';
import 'package:daraz_task/services/api/api_service.dart';
import 'package:daraz_task/services/log/app_log.dart';
import 'package:daraz_task/services/log/error_log.dart';
import 'package:daraz_task/services/storage/storage_service.dart';

class LoginController extends GetxController {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxString errorMessage = ''.obs;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    usernameController.text = 'johnd';
    passwordController.text = 'm38rmF\$';
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void toggleObscure() => obscurePassword.toggle();

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await ApiService.post(
        ApiEndPoint.baseUrl + ApiEndPoint.login,
        body: {
          'username': usernameController.text.trim(),
          'password': passwordController.text.trim(),
        },
      );

      appLog(response.data, source: "Login Response");

      if (response.isSuccess) {
        final token = response.data['token']?.toString() ?? '';
        await AppStorage().setToken(token);
        await AppStorage().setLoginValue(true);
        // FakeStore returns user id 1 for johnd, fetch profile
        await AppStorage().setUserId(1);
        Get.offAllNamed(AppRoutes.homePage);
      } else {
        errorMessage.value = response.message;
      }
    } catch (e) {
      errorLog(e, source: "LoginController.login");
      errorMessage.value = "Login failed. Please try again.";
    } finally {
      isLoading.value = false;
    }
  }
}
