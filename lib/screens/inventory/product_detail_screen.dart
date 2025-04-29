import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/product.dart';
import 'inventory_controller.dart';

class ProductDetailScreen extends GetView<InventoryController> {
  const ProductDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Product product = Get.arguments as Product;
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: product.name);
    final descriptionController = TextEditingController(text: product.description);
    final priceController = TextEditingController(text: product.price.toString());
    final stockController = TextEditingController(text: product.stock.toString());
    final categoryController = TextEditingController(text: product.category);
    final RxString selectedImagePath = ''.obs;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditDialog(
              context,
              product,
              formKey,
              nameController,
              descriptionController,
              priceController,
              stockController,
              categoryController,
              selectedImagePath,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(context, product),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product.imageUrl != null)
              Center(
                child: Image.network(
                  product.imageUrl!,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            _buildInfoSection('Nombre', product.name),
            _buildInfoSection('Descripción', product.description),
            _buildInfoSection('Precio', '\$${product.price.toStringAsFixed(2)}'),
            _buildInfoSection('Stock', product.stock.toString()),
            _buildInfoSection('Categoría', product.category),
            _buildInfoSection(
              'Fecha de Creación',
              product.createdAt.toString().split('.')[0],
            ),
            _buildInfoSection(
              'Última Actualización',
              product.updatedAt.toString().split('.')[0],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 18),
          ),
          const Divider(),
        ],
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    Product product,
    GlobalKey<FormState> formKey,
    TextEditingController nameController,
    TextEditingController descriptionController,
    TextEditingController priceController,
    TextEditingController stockController,
    TextEditingController categoryController,
    RxString selectedImagePath,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Producto'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(() {
                  final imagePath = selectedImagePath.value;
                  if (imagePath.isNotEmpty) {
                    return Image.network(
                      imagePath,
                      height: 100,
                      fit: BoxFit.cover,
                    );
                  } else if (product.imageUrl != null) {
                    return Image.network(
                      product.imageUrl!,
                      height: 100,
                      fit: BoxFit.cover,
                    );
                  }
                  return const SizedBox(height: 100);
                }),
                ElevatedButton.icon(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (image != null) {
                      selectedImagePath.value = image.path;
                    }
                  },
                  icon: const Icon(Icons.image),
                  label: const Text('Cambiar Imagen'),
                ),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Campo requerido' : null,
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  maxLines: 3,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Campo requerido' : null,
                ),
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Precio'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Campo requerido';
                    if (double.tryParse(value!) == null) {
                      return 'Ingrese un número válido';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: stockController,
                  decoration: const InputDecoration(labelText: 'Stock'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Campo requerido';
                    if (int.tryParse(value!) == null) {
                      return 'Ingrese un número válido';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: categoryController.text,
                  decoration: const InputDecoration(labelText: 'Categoría'),
                  items: const [
                    DropdownMenuItem(
                      value: 'Electrónicos',
                      child: Text('Electrónicos'),
                    ),
                    DropdownMenuItem(
                      value: 'Ropa',
                      child: Text('Ropa'),
                    ),
                  ],
                  onChanged: (value) {
                    categoryController.text = value ?? '';
                  },
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Campo requerido' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final updatedProduct = product.copyWith(
                  name: nameController.text,
                  description: descriptionController.text,
                  price: double.parse(priceController.text),
                  stock: int.parse(stockController.text),
                  category: categoryController.text,
                  updatedAt: DateTime.now(),
                );

                XFile? imageFile;
                if (selectedImagePath.value.isNotEmpty) {
                  imageFile = XFile(selectedImagePath.value);
                }

                controller.updateProduct(updatedProduct, imageFile: imageFile);
                Get.back();
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text(
          '¿Está seguro que desea eliminar el producto "${product.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteProduct(product);
              Get.back(); // Volver a la pantalla de inventario
            },
            child: const Text('Eliminar'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
}