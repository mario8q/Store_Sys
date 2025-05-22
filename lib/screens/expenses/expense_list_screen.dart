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
      appBar: AppBar(
        title: const Text(
          'Registro de Gastos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(
        () =>
            controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : controller.expenses.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.attach_money_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay gastos registrados',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Toca el botón + para registrar un gasto',
                        style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                )
                : RefreshIndicator(
                  onRefresh: controller.fetchExpenses,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: controller.expenses.length,
                    itemBuilder: (context, index) {
                      final expense = controller.expenses[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: ExpenseListTile(
                          expense: expense,
                          onDelete: () => _confirmDelete(context, expense),
                        ),
                      );
                    },
                  ),
                ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed:
            () => Get.toNamed('${Routes.expenseList}${Routes.createExpense}'),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Gasto'),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.delete_outline, color: Colors.red),
                const SizedBox(width: 8),
                const Text('Confirmar eliminación'),
              ],
            ),
            content: Text(
              '¿Está seguro que desea eliminar este gasto de ${NumberFormat.currency(locale: 'es_CO', symbol: '\$').format(expense.amount)}?',
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getCategoryIcon(expense.category),
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  expense.category,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                formatter.format(expense.amount),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: Theme.of(context).colorScheme.error,
                  size: 22,
                ),
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                DateFormat('dd/MM/yyyy').format(expense.date),
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
          if (expense.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              expense.description,
              style: TextStyle(color: Colors.grey[800], fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'servicios':
        return Icons.home_repair_service;
      case 'materiales':
        return Icons.build;
      case 'salarios':
        return Icons.people;
      case 'transporte':
        return Icons.local_shipping;
      case 'mantenimiento':
        return Icons.build_circle;
      case 'otros':
        return Icons.more_horiz;
      default:
        return Icons.attach_money;
    }
  }
}
