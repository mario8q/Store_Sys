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
      appBar: AppBar(title: const Text('Historial de Ventas')),
      body: Obx(
        () =>
            controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : controller.sales.isEmpty
                ? const Center(child: Text('No hay ventas registradas'))
                : RefreshIndicator(
                  onRefresh: controller.fetchSales,
                  child: ListView.builder(
                    itemCount: controller.sales.length,
                    itemBuilder: (context, index) {
                      final sale = controller.sales[index];
                      return SaleListTile(
                        sale: sale,
                        onDelete: () => _confirmDelete(context, sale),
                      );
                    },
                  ),
                ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('${Routes.saleList}${Routes.createSale}'),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Sale sale) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: const Text('¿Está seguro que desea eliminar esta venta?'),
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
      title: Text(formatter.format(sale.total)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${sale.items.length} productos'),
          Text(
            DateFormat('dd/MM/yyyy').format(sale.date),
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
      trailing: IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
    );
  }
}
