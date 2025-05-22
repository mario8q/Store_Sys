import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/product.dart';
import 'inventory_controller.dart';

class CreateProductScreen extends StatefulWidget {
  const CreateProductScreen({Key? key}) : super(key: key);

  @override
  State<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController nameController;
  late final TextEditingController descriptionController;
  late final TextEditingController priceController;
  late final TextEditingController stockController;
  late final TextEditingController categoryController;
  final selectedImagePath = ''.obs;
  late final InventoryController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<InventoryController>();
    nameController = TextEditingController();
    descriptionController = TextEditingController();
    priceController = TextEditingController();
    stockController = TextEditingController();
    categoryController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    stockController.dispose();
    categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Crear Producto',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
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
                Obx(() {
                  return GestureDetector(
                    onTap: _selectImage,
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child:
                          selectedImagePath.value.isNotEmpty
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.file(
                                  File(selectedImagePath.value),
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              )
                              : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate_outlined,
                                    size: 64,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Añadir imagen',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                    ),
                  );
                }),
                const SizedBox(height: 24),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Producto',
                    prefixIcon: Icon(Icons.inventory),
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
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.description),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese una descripción';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Precio',
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese el precio';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Precio inválido';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: stockController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Stock',
                          prefixIcon: Icon(Icons.inventory_2),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese el stock';
                          }
                          if (int.tryParse(value) == null) {
                            return 'Stock inválido';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    prefixIcon: Icon(Icons.category),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese una categoría';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _createProduct,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'CREAR PRODUCTO',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null) {
        final file = File(image.path);
        if (await file.exists()) {
          selectedImagePath.value = image.path;
          debugPrint('Imagen seleccionada: ${image.path}');
        } else {
          debugPrint('El archivo de imagen no existe');
          Get.snackbar(
            'Error',
            'No se pudo acceder a la imagen seleccionada',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      debugPrint('Error al seleccionar imagen: $e');
      Get.snackbar(
        'Error',
        'Error al seleccionar la imagen',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _createProduct() async {
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
        await controller.createProduct(product, image: imageFile);
        Get.back();
      } catch (e) {
        Get.snackbar(
          'Error',
          'No se pudo crear el producto: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }
}
