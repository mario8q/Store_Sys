import 'package:get/get.dart';
import '../../services/auth_repository.dart';
import '../../data/providers/appwrite_provider.dart';
import 'inventory_controller.dart';

class InventoryBinding extends Bindings {
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

    Get.put(InventoryController(authRepository: Get.find<AuthRepository>()));
  }
}
