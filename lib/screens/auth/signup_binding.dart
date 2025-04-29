import 'package:get/get.dart';
import '../../data/providers/appwrite_provider.dart';
import '../../services/auth_repository.dart';
import 'signup_controller.dart';

class SignUpBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AppwriteProvider>()) {
      Get.put(AppwriteProvider(), permanent: true);
    }
    if (!Get.isRegistered<AuthRepository>()) {
      Get.put(
        AuthRepository(appwrite: Get.find<AppwriteProvider>()),
        permanent: true,
      );
    }
    Get.put(SignUpController(authRepository: Get.find<AuthRepository>()));
  }
}
