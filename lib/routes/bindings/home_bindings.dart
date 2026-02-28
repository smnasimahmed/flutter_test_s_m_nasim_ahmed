import 'package:get/get.dart';
import 'package:daraz_task/home_screen/controller/home_page_controller.dart';

class HomeBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomePageController());
  }
}
