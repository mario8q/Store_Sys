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
        title: const Text(
          'Inventario',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.account_circle, size: 28),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showOptionsMenu(context),
          ),
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
                accountName: Text(
                  user?.name ?? 'Usuario',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                accountEmail: Text(
                  user?.email ?? '',
                  style: TextStyle(color: Colors.black87.withOpacity(0.8)),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Theme.of(context).primaryColor,
                  ),
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
                Get.back();
                Get.toNamed(Routes.editProfile);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                Get.back();
                await controller.logout();
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar productos...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
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
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay productos disponibles',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                      : RefreshIndicator(
                        onRefresh: controller.fetchProducts,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: controller.products.length,
                          itemBuilder: (context, index) {
                            final product = controller.products[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              child: ProductListTile(
                                product: product,
                                onTap:
                                    () => _showProductDetails(context, product),
                                onDelete:
                                    () => _confirmDelete(context, product),
                              ),
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
            title: Row(
              children: [
                Icon(Icons.filter_list, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text('Filtrar por categoría'),
              ],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Obx(
              () => SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<String>(
                      title: const Text(
                        'Todos',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      value: '',
                      groupValue: controller.selectedCategory.value,
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (value) {
                        controller.setSelectedCategory(value ?? '');
                        Get.back();
                      },
                    ),
                    const Divider(),
                    ...controller.getUniqueCategories().map(
                      (category) => RadioListTile<String>(
                        title: Text(
                          category,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        value: category,
                        groupValue: controller.selectedCategory.value,
                        activeColor: Theme.of(context).primaryColor,
                        onChanged: (value) {
                          controller.setSelectedCategory(value ?? '');
                          Get.back();
                        },
                      ),
                    ),
                  ],
                ),
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

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.attach_money,
                  color: Theme.of(context).primaryColor,
                ),
                title: const Text(
                  'Gastos',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Get.back();
                  Get.toNamed(Routes.expenseList);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(
                  Icons.point_of_sale,
                  color: Theme.of(context).primaryColor,
                ),
                title: const Text(
                  'Ventas',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Get.back();
                  Get.toNamed(Routes.saleList);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(
                  Icons.balance,
                  color: Theme.of(context).primaryColor,
                ),
                title: const Text(
                  'Ver Balance',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Get.back();
                  Get.toNamed(Routes.balance);
                },
              ),
            ],
          ),
        );
      },
    );
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading:
          product.imageUrl != null
              ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.imageUrl!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                        ),
                      ),
                ),
              )
              : Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.inventory_2, color: Colors.grey),
              ),
      title: Text(
        product.name,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.inventory, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                'Stock: ${product.stock}',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(width: 12),
              Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            product.category,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.red),
        onPressed: onDelete,
      ),
      onTap: onTap,
    );
  }
}
