import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/models/product.dart';
import '../inventory/inventory_controller.dart';
import 'sale_controller.dart';

class CreateSaleScreen extends GetView<SaleController> {
  const CreateSaleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final inventoryController = Get.find<InventoryController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Venta')),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () =>
                  inventoryController.isLoading.value
                      ? const Center(child: CircularProgressIndicator())
                      : GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                        itemCount: inventoryController.products.length,
                        itemBuilder: (context, index) {
                          final product = inventoryController.products[index];
                          return Obx(
                            () => _ProductCard(
                              product: product,
                              selectedQuantity:
                                  controller.selectedProducts[product.id] ?? 0,
                              onIncrement:
                                  () => controller.updateProductQuantity(
                                    product.id,
                                    true,
                                  ),
                              onDecrement:
                                  () => controller.updateProductQuantity(
                                    product.id,
                                    false,
                                  ),
                            ),
                          );
                        },
                      ),
            ),
          ),
          _buildTotalAndConfirm(),
        ],
      ),
    );
  }

  Widget _buildTotalAndConfirm() {
    final formatter = NumberFormat.currency(locale: 'es_CO', symbol: '\$');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(
            () => Text(
              'Total: ${formatter.format(controller.currentTotal.value)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Obx(
              () => ElevatedButton(
                onPressed:
                    controller.selectedProducts.isEmpty
                        ? null
                        : () => _showDatePicker(),
                child: const Text('Confirmar Venta'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDatePicker() {
    showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    ).then((date) {
      if (date != null) {
        controller.createSale(date);
      }
    });
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final int selectedQuantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _ProductCard({
    required this.product,
    required this.selectedQuantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'es_CO', symbol: '\$');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product.imageUrl != null)
              Expanded(
                child: Center(
                  child: Image.network(product.imageUrl!, fit: BoxFit.cover),
                ),
              ),
            if (product.imageUrl == null)
              const Expanded(
                child: Center(
                  child: Icon(Icons.inventory, size: 50, color: Colors.grey),
                ),
              ),
            Text(
              product.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              formatter.format(product.price),
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              'Stock: ${product.stock}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: selectedQuantity > 0 ? onDecrement : null,
                ),
                Text(
                  '$selectedQuantity',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed:
                      selectedQuantity < product.stock ? onIncrement : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
