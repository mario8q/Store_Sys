import 'package:get/get.dart';
import 'app_routes.dart';
import '../screens/splash/splash_binding.dart';
import '../screens/splash/splash_view.dart';
import '../screens/auth/login_binding.dart';
import '../screens/auth/login_view.dart';
import '../screens/auth/signup_binding.dart';
import '../screens/auth/signup_view.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.signup,
      page: () => const SignUpView(),
      binding: SignUpBinding(),
    ),
  ];
}
