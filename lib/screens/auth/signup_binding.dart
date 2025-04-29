import 'package:get/get.dart';
import '../../data/providers/appwrite_provider.dart';
import '../../services/auth_repository.dart';
import 'signup_controller.dart';

class SignUpBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AppwriteProvider());
    Get.put(AuthRepository(appwrite: Get.find<AppwriteProvider>()));
    Get.put(SignUpController(authRepository: Get.find<AuthRepository>()));
  }
}
