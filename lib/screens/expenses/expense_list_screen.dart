import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/models/expense.dart';
import '../../routes/app_routes.dart';
import 'expense_controller.dart';

class ExpenseListScreen extends GetView<ExpenseController> {
  const ExpenseListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Gastos')),
      body: Obx(
        () =>
            controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : controller.expenses.isEmpty
                ? const Center(child: Text('No hay gastos registrados'))
                : RefreshIndicator(
                  onRefresh: controller.fetchExpenses,
                  child: ListView.builder(
                    itemCount: controller.expenses.length,
                    itemBuilder: (context, index) {
                      final expense = controller.expenses[index];
                      return ExpenseListTile(
                        expense: expense,
                        onDelete: () => _confirmDelete(context, expense),
                      );
                    },
                  ),
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => Get.toNamed('${Routes.expenseList}${Routes.createExpense}'),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: Text('¿Está seguro que desea eliminar el gasto?'),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Get.back();
                  controller.deleteExpense(expense.id);
                },
                child: const Text('Eliminar'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
    );
  }
}

class ExpenseListTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback onDelete;

  const ExpenseListTile({
    Key? key,
    required this.expense,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'es_CO', symbol: '\$');
    return ListTile(
      title: Text(formatter.format(expense.amount)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(expense.category),
          Text(
            DateFormat('dd/MM/yyyy').format(expense.date),
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
      trailing: IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
    );
  }
}
