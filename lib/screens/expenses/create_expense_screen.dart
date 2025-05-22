import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/expense.dart';
import 'expense_controller.dart';
import '../inventory/inventory_controller.dart';

class CreateExpenseScreen extends StatefulWidget {
  const CreateExpenseScreen({Key? key}) : super(key: key);

  @override
  State<CreateExpenseScreen> createState() => _CreateExpenseScreenState();
}

class _CreateExpenseScreenState extends State<CreateExpenseScreen> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController descriptionController;
  late final TextEditingController amountController;
  final selectedDate = DateTime.now().obs;
  final selectedCategory = Expense.categories.first.obs;
  final selectedPaymentMethod = Expense.paymentMethods.first.obs;
  late final ExpenseController controller;
  late final InventoryController inventoryController;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ExpenseController>();
    inventoryController = Get.find<InventoryController>();
    descriptionController = TextEditingController();
    amountController = TextEditingController();
  }

  @override
  void dispose() {
    descriptionController.dispose();
    amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      selectedDate.value = picked;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Registrar Gasto',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Fecha
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: Icon(
                    Icons.calendar_today,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Obx(
                    () => Text(
                      'Fecha: ${selectedDate.value.day}/${selectedDate.value.month}/${selectedDate.value.year}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  onTap: () => _selectDate(context),
                ),
              ),
              const SizedBox(height: 16),

              // Categoría
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Categoría',
                      border: InputBorder.none,
                      labelStyle: TextStyle(color: Colors.grey[700]),
                      icon: Icon(
                        Icons.category,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    value: selectedCategory.value,
                    items:
                        Expense.categories
                            .map(
                              (category) => DropdownMenuItem(
                                value: category,
                                child: Text(
                                  category,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        selectedCategory.value = value;
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Método de pago
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Método de pago',
                      border: InputBorder.none,
                      labelStyle: TextStyle(color: Colors.grey[700]),
                      icon: Icon(
                        Icons.payment,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    value: selectedPaymentMethod.value,
                    items:
                        Expense.paymentMethods
                            .map(
                              (method) => DropdownMenuItem(
                                value: method,
                                child: Text(
                                  method,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        selectedPaymentMethod.value = value;
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Monto
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Monto',
                    prefixIcon: Icon(
                      Icons.attach_money,
                      color: Theme.of(context).primaryColor,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese el monto';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Por favor ingrese un monto válido';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Descripción
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Descripción',
                    prefixIcon: Icon(
                      Icons.description,
                      color: Theme.of(context).primaryColor,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese una descripción';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Botón guardar
              ElevatedButton(
                onPressed: _createExpense,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'GUARDAR GASTO',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createExpense() {
    if (formKey.currentState!.validate()) {
      controller.createExpense(
        selectedDate.value,
        selectedCategory.value,
        double.parse(amountController.text),
        selectedPaymentMethod.value,
        descriptionController.text,
      );
    }
  }
}
