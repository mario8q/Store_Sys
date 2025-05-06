import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/product.dart';
import 'inventory_controller.dart';

class CreateProductScreen extends GetView<InventoryController> {
  const CreateProductScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController();
    final categoryController = TextEditingController();
    final RxString selectedImagePath = ''.obs;

    // Asegurar que los controladores se limpien al salir
    Get.put(nameController, tag: 'create_name');
    Get.put(descriptionController, tag: 'create_description');
    Get.put(priceController, tag: 'create_price');
    Get.put(stockController, tag: 'create_stock');
    Get.put(categoryController, tag: 'create_category');

    return WillPopScope(
      onWillPop: () async {
        _disposeControllers();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Crear Producto'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              _disposeControllers();
              Get.back();
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Obx(() {
                  if (selectedImagePath.value.isNotEmpty) {
                    return Container(
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(selectedImagePath.value),
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }
                  return Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
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
                  label: const Text('Seleccionar Imagen'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Producto',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese el nombre del producto';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese una descripción';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'Precio',
                    border: OutlineInputBorder(),
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese el precio';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Por favor ingrese un precio válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: stockController,
                  decoration: const InputDecoration(
                    labelText: 'Stock',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese el stock';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Por favor ingrese un número válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Electrónicos',
                      child: Text('Electrónicos'),
                    ),
                    DropdownMenuItem(value: 'Ropa', child: Text('Ropa')),
                  ],
                  onChanged: (value) {
                    categoryController.text = value ?? '';
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor seleccione una categoría';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final product = Product(
                        id: '',
                        name: nameController.text,
                        description: descriptionController.text,
                        price: double.parse(priceController.text),
                        stock: int.parse(stockController.text),
                        category: categoryController.text,
                        userId: controller.currentUser.value?.id ?? '',
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      );

                      XFile? imageFile;
                      if (selectedImagePath.value.isNotEmpty) {
                        imageFile = XFile(selectedImagePath.value);
                      }

                      try {
                        await controller.createProduct(
                          product,
                          image: imageFile,
                        );
                        _disposeControllers();
                        Get.back();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al crear el producto: $e'),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Crear Producto'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _disposeControllers() {
    // Limpiar los controladores al salir de la pantalla
    if (Get.isRegistered<TextEditingController>(tag: 'create_name')) {
      Get.find<TextEditingController>(tag: 'create_name').dispose();
      Get.delete<TextEditingController>(tag: 'create_name');
    }
    if (Get.isRegistered<TextEditingController>(tag: 'create_description')) {
      Get.find<TextEditingController>(tag: 'create_description').dispose();
      Get.delete<TextEditingController>(tag: 'create_description');
    }
    if (Get.isRegistered<TextEditingController>(tag: 'create_price')) {
      Get.find<TextEditingController>(tag: 'create_price').dispose();
      Get.delete<TextEditingController>(tag: 'create_price');
    }
    if (Get.isRegistered<TextEditingController>(tag: 'create_stock')) {
      Get.find<TextEditingController>(tag: 'create_stock').dispose();
      Get.delete<TextEditingController>(tag: 'create_stock');
    }
    if (Get.isRegistered<TextEditingController>(tag: 'create_category')) {
      Get.find<TextEditingController>(tag: 'create_category').dispose();
      Get.delete<TextEditingController>(tag: 'create_category');
    }
  }
}
