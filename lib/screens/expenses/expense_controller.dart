import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/expense.dart';
import '../../data/providers/expense_provider.dart';
import '../../data/models/user_model.dart';
import '../inventory/inventory_controller.dart';

class ExpenseController extends GetxController {
  final ExpenseProvider _expenseProvider = ExpenseProvider();
  final RxBool isLoading = false.obs;
  final RxList<Expense> expenses = <Expense>[].obs;
  late final Rx<UserModel?> currentUser;

  @override
  void onInit() {
    super.onInit();
    // Obtener el currentUser del InventoryController
    currentUser = Get.find<InventoryController>().currentUser;
    fetchExpenses();
  }

  Future<void> createExpense(
    DateTime date,
    String category,
    double amount,
    String paymentMethod,
    String description,
  ) async {
    try {
      if (currentUser.value == null) {
        throw 'Usuario no autenticado';
      }

      isLoading.value = true;
      final expense = Expense(
        id: '',
        date: date,
        category: category,
        amount: amount,
        paymentMethod: paymentMethod,
        description: description,
        userId: currentUser.value!.id,
      );

      final createdExpense = await _expenseProvider.createExpense(expense);
      expenses.add(createdExpense);
      Get.back();
      Get.snackbar(
        'Éxito',
        'Gasto registrado correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo registrar el gasto: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchExpenses() async {
    try {
      if (currentUser.value == null) {
        throw 'Usuario no autenticado';
      }

      isLoading.value = true;
      final fetchedExpenses = await _expenseProvider.getExpenses(
        currentUser.value!.id,
      );
      expenses.value = fetchedExpenses;
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron cargar los gastos: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    try {
      isLoading.value = true;
      await _expenseProvider.deleteExpense(expenseId);
      expenses.removeWhere((e) => e.id == expenseId);
      Get.snackbar(
        'Éxito',
        'Gasto eliminado correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo eliminar el gasto: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
