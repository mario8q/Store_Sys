import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/product.dart';
import '../../routes/app_routes.dart';
import 'inventory_controller.dart';

class InventoryScreen extends GetView<InventoryController> {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario'),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Obx(() {
              final user = controller.currentUser.value;
              return UserAccountsDrawerHeader(
                accountName: Text(user?.name ?? 'Usuario'),
                accountEmail: Text(user?.email ?? ''),
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 50, color: Colors.blue),
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
              );
            }),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Editar Perfil'),
              onTap: () {
                Get.back(); // Cierra el drawer
                Get.toNamed(Routes.editProfile);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar Sesión'),
              onTap: () async {
                Get.back(); // Cierra el drawer
                await controller.logout();
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar productos...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: controller.setSearchQuery,
            ),
          ),
          Expanded(
            child: Obx(
              () =>
                  controller.isLoading.value
                      ? const Center(child: CircularProgressIndicator())
                      : controller.products.isEmpty
                      ? const Center(
                        child: Text('No hay productos disponibles'),
                      )
                      : RefreshIndicator(
                        onRefresh: controller.fetchProducts,
                        child: ListView.builder(
                          itemCount: controller.products.length,
                          itemBuilder: (context, index) {
                            final product = controller.products[index];
                            return ProductListTile(
                              product: product,
                              onTap:
                                  () => _showProductDetails(context, product),
                              onDelete: () => _confirmDelete(context, product),
                            );
                          },
                        ),
                      ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProductDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Filtrar por categoría'),
            content: Obx(
              () => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: const Text('Todos'),
                    value: '',
                    groupValue: controller.selectedCategory.value,
                    onChanged: (value) {
                      controller.setSelectedCategory(value ?? '');
                      Get.back();
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Electrónicos'),
                    value: 'Electrónicos',
                    groupValue: controller.selectedCategory.value,
                    onChanged: (value) {
                      controller.setSelectedCategory(value ?? '');
                      Get.back();
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Ropa'),
                    value: 'Ropa',
                    groupValue: controller.selectedCategory.value,
                    onChanged: (value) {
                      controller.setSelectedCategory(value ?? '');
                      Get.back();
                    },
                  ),
                  // Agregar más categorías según sea necesario
                ],
              ),
            ),
          ),
    );
  }

  void _showProductDetails(BuildContext context, Product product) {
    Get.toNamed(Routes.productDetail, arguments: product);
  }

  void _confirmDelete(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: Text('¿Está seguro que desea eliminar ${product.name}?'),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Get.back();
                  controller.deleteProduct(product);
                },
                child: const Text('Eliminar'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    Get.toNamed(Routes.createProduct);
  }
}

class ProductListTile extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ProductListTile({
    Key? key,
    required this.product,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading:
          product.imageUrl != null
              ? CircleAvatar(backgroundImage: NetworkImage(product.imageUrl!))
              : const CircleAvatar(child: Icon(Icons.inventory)),
      title: Text(product.name),
      subtitle: Text(
        'Stock: ${product.stock} - Precio: \$${product.price.toStringAsFixed(2)}',
      ),
      trailing: IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
      onTap: onTap,
    );
  }
}
