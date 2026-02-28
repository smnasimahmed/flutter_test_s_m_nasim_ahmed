import 'package:get/get.dart';
import 'package:daraz_task/home_screen/home_page.dart';
import 'package:daraz_task/profile_screen/profile_page.dart';
import 'package:daraz_task/splash_screen/login_page.dart';
import 'package:daraz_task/routes/app_routes.dart';
import 'package:daraz_task/routes/bindings/auth_bindings.dart';
import 'package:daraz_task/routes/bindings/home_bindings.dart';

List<GetPage> appRouteFile = <GetPage>[
  GetPage(
    name: AppRoutes.loginPage,
    page: () => const LoginPage(),
    binding: AuthBindings(),
  ),
  GetPage(
    name: AppRoutes.homePage,
    page: () => const HomePage(),
    binding: HomeBindings(),
  ),
  GetPage(
    name: AppRoutes.profilePage,
    page: () => const ProfilePage(),
  ),
];
