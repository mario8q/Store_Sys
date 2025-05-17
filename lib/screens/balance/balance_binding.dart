import 'package:get/get.dart';
import './balance_controller.dart';
import '../../data/providers/sale_provider.dart';
import '../../data/providers/expense_provider.dart';
import '../../data/providers/appwrite_provider.dart';
import '../inventory/inventory_controller.dart';

class BalanceBinding extends Bindings {
  @override
  void dependencies() {
    // Asegurarse de que AppwriteProvider esté disponible
    if (!Get.isRegistered<AppwriteProvider>()) {
      Get.put(AppwriteProvider(), permanent: true);
    }

    // Asegurarse de que InventoryController esté disponible
    if (!Get.isRegistered<InventoryController>()) {
      Get.put(InventoryController(authRepository: Get.find()));
    }

    Get.lazyPut<SaleProvider>(() => SaleProvider());
    Get.lazyPut<ExpenseProvider>(() => ExpenseProvider());
    Get.lazyPut<BalanceController>(() => BalanceController());
  }
}
// ... existing code ... 