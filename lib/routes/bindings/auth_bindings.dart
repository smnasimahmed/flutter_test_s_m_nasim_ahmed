import 'package:get/get.dart';
import 'package:daraz_task/splash_screen/controller/login_controller.dart';

class AuthBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController());
  }
}
