import 'package:get/get.dart';
import '../../services/auth_repository.dart';
import '../../data/providers/appwrite_provider.dart';
import '../inventory/inventory_controller.dart';
import 'expense_controller.dart';

class ExpenseBinding extends Bindings {
  @override
  void dependencies() {
    // Asegurarnos de que AppwriteProvider esté disponible
    if (!Get.isRegistered<AppwriteProvider>()) {
      Get.put(AppwriteProvider(), permanent: true);
    }

    // Asegurarnos de que AuthRepository esté disponible
    if (!Get.isRegistered<AuthRepository>()) {
      Get.put(
        AuthRepository(appwrite: Get.find<AppwriteProvider>()),
        permanent: true,
      );
    }

    // Asegurarnos de que InventoryController esté disponible
    if (!Get.isRegistered<InventoryController>()) {
      Get.put(InventoryController(authRepository: Get.find<AuthRepository>()));
    }

    // Registrar ExpenseController
    Get.put(ExpenseController());
  }
}
