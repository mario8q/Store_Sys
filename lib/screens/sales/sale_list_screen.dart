import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/models/sale.dart';
import '../../routes/app_routes.dart';
import 'sale_controller.dart';

class SaleListScreen extends GetView<SaleController> {
  const SaleListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Historial de Ventas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Obx(
        () =>
            controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : controller.sales.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.point_of_sale,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay ventas registradas',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Toca el botón + para crear una venta',
                        style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                )
                : RefreshIndicator(
                  onRefresh: controller.fetchSales,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: controller.sales.length,
                    itemBuilder: (context, index) {
                      final sale = controller.sales[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: SaleListTile(
                          sale: sale,
                          onDelete: () => _confirmDelete(context, sale),
                        ),
                      );
                    },
                  ),
                ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed('${Routes.saleList}${Routes.createSale}'),
        icon: const Icon(Icons.add),
        label: const Text('Nueva Venta'),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Sale sale) {
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
            content: const Text('¿Está seguro que desea eliminar esta venta?'),
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
                  controller.deleteSale(sale.id);
                },
                child: const Text('Eliminar'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
    );
  }
}

class SaleListTile extends StatelessWidget {
  final Sale sale;
  final VoidCallback onDelete;

  const SaleListTile({Key? key, required this.sale, required this.onDelete})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'es_CO', symbol: '\$');
    return ListTile(
      contentPadding: const EdgeInsets.all(16),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.shopping_cart,
                size: 20,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                '${sale.items.length} productos',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Text(
            formatter.format(sale.total),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                DateFormat('dd/MM/yyyy').format(sale.date),
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children:
                sale.items
                    .map(
                      (item) => Chip(
                        label: Text(
                          '${item.productName} (${item.quantity})',
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: Theme.of(
                          context,
                        ).primaryColor.withOpacity(0.1),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.red),
        onPressed: onDelete,
      ),
    );
  }
}
