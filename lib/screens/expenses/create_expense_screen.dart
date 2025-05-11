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
        title: const Text('Registrar Gasto'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
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
              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Obx(
                    () => Text(
                      'Fecha: ${selectedDate.value.day}/${selectedDate.value.month}/${selectedDate.value.year}',
                    ),
                  ),
                  onTap: () => _selectDate(context),
                ),
              ),
              const SizedBox(height: 16),

              // Categoría
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Categoría',
                      border: InputBorder.none,
                    ),
                    value: selectedCategory.value,
                    items:
                        Expense.categories
                            .map(
                              (category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value != null) selectedCategory.value = value;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Valor del gasto
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: TextFormField(
                    controller: amountController,
                    decoration: const InputDecoration(
                      labelText: 'Valor del gasto',
                      prefixText: '\$',
                      border: InputBorder.none,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese el valor';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Por favor ingrese un valor válido';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Método de pago
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Método de pago',
                      border: InputBorder.none,
                    ),
                    value: selectedPaymentMethod.value,
                    items:
                        Expense.paymentMethods
                            .map(
                              (method) => DropdownMenuItem(
                                value: method,
                                child: Text(method),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value != null) selectedPaymentMethod.value = value;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Descripción
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      border: InputBorder.none,
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese una descripción';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Botón de registro
              ElevatedButton.icon(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    controller.createExpense(
                      selectedDate.value,
                      selectedCategory.value,
                      double.parse(amountController.text),
                      selectedPaymentMethod.value,
                      descriptionController.text,
                    );
                  }
                },
                icon: const Icon(Icons.save),
                label: const Text('Registrar Gasto'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
