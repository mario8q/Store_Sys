import 'package:get/get.dart';
import '../../data/providers/appwrite_provider.dart';
import '../../services/auth_repository.dart';
import 'login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AppwriteProvider());
    Get.put(AuthRepository(appwrite: Get.find<AppwriteProvider>()));
    Get.put(LoginController(authRepository: Get.find<AuthRepository>()));
  }
}
