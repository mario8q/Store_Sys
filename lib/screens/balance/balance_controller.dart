import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/providers/sale_provider.dart';
import '../../data/providers/expense_provider.dart';
import '../../data/models/sale.dart';
import '../../data/models/expense.dart';
import '../inventory/inventory_controller.dart';
import '../../services/auth_repository.dart';

class BalanceController extends GetxController {
  late final SaleProvider _saleProvider;
  late final ExpenseProvider _expenseProvider;
  late final InventoryController _inventoryController;
  late final AuthRepository _authRepository;

  var totalIngresos = 0.0.obs;
  var totalEgresos = 0.0.obs;
  var balanceActual = 0.0.obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeDependencies();
  }

  void _initializeDependencies() {
    try {
      debugPrint('Inicializando dependencias del BalanceController');

      // Obtener las dependencias
      _saleProvider = Get.find<SaleProvider>();
      _expenseProvider = Get.find<ExpenseProvider>();
      _inventoryController = Get.find<InventoryController>();
      _authRepository = Get.find<AuthRepository>();

      debugPrint('Dependencias inicializadas correctamente');

      // Cargar datos después de inicializar dependencias
      fetchBalanceData();
    } catch (e) {
      debugPrint('Error al inicializar dependencias: $e');
      Get.snackbar(
        'Error',
        'Error al inicializar la pantalla de balance',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      isLoading.value = false;
    }
  }

  Future<void> fetchBalanceData() async {
    try {
      debugPrint('Iniciando fetchBalanceData');
      isLoading.value = true;

      // Obtener el usuario actual
      final user = await _authRepository.getCurrentUser();
      debugPrint('Usuario actual obtenido: ${user.toMap()}');

      if (user == null) {
        throw 'Usuario no autenticado';
      }

      // Obtener ventas y gastos
      debugPrint('Obteniendo ventas y gastos');
      final sales = await _saleProvider.getSales(user.$id);
      final expenses = await _expenseProvider.getExpenses(user.$id);

      debugPrint('Ventas obtenidas: ${sales.length}');
      debugPrint('Gastos obtenidos: ${expenses.length}');

      // Calcular totales
      totalIngresos.value = sales.fold(0.0, (sum, sale) => sum + sale.total);
      totalEgresos.value = expenses.fold(
        0.0,
        (sum, expense) => sum + expense.amount,
      );
      balanceActual.value = totalIngresos.value - totalEgresos.value;

      debugPrint(
        'Cálculos completados: Ingresos=${totalIngresos.value}, Egresos=${totalEgresos.value}, Balance=${balanceActual.value}',
      );
    } catch (e) {
      debugPrint('Error en fetchBalanceData: $e');
      Get.snackbar(
        'Error',
        'Error al cargar datos del balance: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      totalIngresos.value = 0.0;
      totalEgresos.value = 0.0;
      balanceActual.value = 0.0;
    } finally {
      isLoading.value = false;
      debugPrint('fetchBalanceData completado');
    }
  }

  Future<void> refreshData() async {
    await fetchBalanceData();
  }

  // TODO: Preparar datos para la gráfica (depende del tipo de gráfica a usar)
}
