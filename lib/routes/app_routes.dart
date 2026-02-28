import 'package:daraz_task/services/storage/storage_service.dart';

class AppRoutes {
  AppRoutes._();

  static const loginPage = '/loginPage';
  static const homePage = '/homePage';
  static const profilePage = '/profilePage';
  static const productDetailPage = '/productDetailPage';

  static String initialPage() {
    if (AppStorage().getLoginValue()) {
      return homePage;
    } else {
      return loginPage;
    }
  }
}
