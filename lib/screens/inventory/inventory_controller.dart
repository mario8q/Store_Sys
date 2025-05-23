import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:appwrite/appwrite.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/appwrite_config.dart';
import '../../data/models/product.dart';
import '../../data/models/user_model.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_repository.dart';
import '../../data/local/local_product_repository.dart';

class InventoryController extends GetxController {
  final client = Get.find<Client>();
  late final Account account;
  late final Databases databases;
  late final Storage storage;
  final AuthRepository _authRepository;
  final LocalProductRepository _localRepo;

  final RxList<Product> products = <Product>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = ''.obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  InventoryController({required AuthRepository authRepository})
    : _authRepository = authRepository,
      _localRepo = LocalProductRepository();

  @override
  void onInit() {
    super.onInit();
    account = Account(client);
    databases = Databases(client);
    storage = Storage(client);
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await loadUserData();
      await _localRepo.resetDatabase(); // Reset database to ensure clean state
      await fetchProducts();
    } catch (e) {
      debugPrint('Error initializing data: $e');
      // Si hay un error al cargar los datos, probablemente la sesión expiró
      await logout();
    }
  }

  Future<void> loadUserData() async {
    try {
      final user = await _authRepository.getCurrentUser();
      currentUser.value = UserModel.fromJson(user.toMap());
    } catch (e) {
      debugPrint('Error loading user data: $e');
      throw e; // Propagar el error para que _initializeData lo maneje
    }
  }

  Future<void> logout() async {
    try {
      final storage = GetStorage();
      final sessionId = storage.read('sessionId');
      if (sessionId != null) {
        await _authRepository.logout(sessionId);
      }
      await storage.erase();
      Get.offAllNamed(Routes.login);
    } catch (e) {
      debugPrint('Error during logout: $e');
      // Incluso si hay un error, intentamos limpiar el storage y navegar al login
      final storage = GetStorage();
      await storage.erase();
      Get.offAllNamed(Routes.login);
    }
  }

  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      final userId = currentUser.value?.id;
      if (userId == null) {
        throw 'Usuario no autenticado';
      }

      try {
        // Intentar obtener productos de Appwrite primero
        final remoteProducts = await _getAllProducts();

        // Guardar en SQLite
        await _localRepo.saveProducts(remoteProducts);

        // Cargar desde SQLite
        products.value = await _localRepo.getProducts(userId);
      } catch (e) {
        debugPrint('Error fetching from Appwrite, using local data: $e');
        // Si falla Appwrite, usar datos locales
        products.value = await _localRepo.getProducts(userId);
      }

      // Aplicar filtros si hay alguno activo
      if (searchQuery.value.isNotEmpty || selectedCategory.value.isNotEmpty) {
        filterProducts();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron cargar los productos: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createProduct(Product product, {XFile? image}) async {
    try {
      isLoading.value = true;
      final userId = currentUser.value?.id;
      if (userId == null) {
        throw 'Usuario no autenticado';
      }

      String? imageId;
      if (image != null) {
        try {
          final uniqueId = ID.unique();
          final originalFilename = image.name;
          final extension = originalFilename.split('.').last;
          final safeFilename = '$uniqueId.$extension';

          final file = await storage.createFile(
            bucketId: AppwriteConfig.productsBucketId,
            fileId: uniqueId,
            file: InputFile.fromPath(path: image.path, filename: safeFilename),
            permissions: [
              Permission.read(Role.any()),
              Permission.write(Role.user(userId)),
            ],
          );

          imageId = file.$id;
        } catch (e) {
          debugPrint('Error al subir la imagen: $e');
          throw 'Error al subir la imagen: $e';
        }
      }
      final documentId = ID.unique();
      final now = DateTime.now();
      final productWithUserId = product.copyWith(
        userId: userId,
        id: documentId,
        createdAt: now,
        updatedAt: now,
      );

      final productData = {
        ...productWithUserId.toJson(),
        if (imageId != null) 'imageUrl': imageId,
      };

      try {
        // Crear en Appwrite
        final response = await databases.createDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.productsCollectionId,
          documentId: documentId,
          data: productData,
        );

        final newProduct = Product.fromJson(response.data);

        // Guardar en SQLite
        await _localRepo.saveProduct(newProduct);

        // Actualizar la lista local
        products.add(newProduct);
      } catch (e) {
        debugPrint('Error creating product in Appwrite: $e');
        // Si falla Appwrite, guardar solo localmente
        final localProduct = productWithUserId.copyWith(id: documentId);
        await _localRepo.saveProduct(localProduct);
        products.add(localProduct);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo crear el producto: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProduct(Product product, {XFile? image}) async {
    try {
      isLoading.value = true;
      String? imageId;

      if (image != null) {
        // Si hay una imagen existente, obtener su ID y eliminarla
        if (product.imageUrl != null) {
          final existingImageId =
              product.imageUrl!.split('/').last.split('?').first;
          try {
            await storage.deleteFile(
              bucketId: AppwriteConfig.productsBucketId,
              fileId: existingImageId,
            );
          } catch (e) {
            debugPrint('Error al eliminar imagen anterior: $e');
          }
        }

        // Subir la nueva imagen
        final uniqueId = ID.unique();
        try {
          final file = await storage.createFile(
            bucketId: AppwriteConfig.productsBucketId,
            fileId: uniqueId,
            file: InputFile.fromPath(path: image.path),
            permissions: [
              Permission.read(Role.any()),
              Permission.write(Role.user(product.userId)),
            ],
          );
          imageId = file.$id;
        } catch (e) {
          debugPrint('Error al subir nueva imagen: $e');
          throw 'Error al subir la imagen: $e';
        }
      }

      try {
        // Actualizar en Appwrite
        final response = await databases.updateDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.productsCollectionId,
          documentId: product.id,
          data: {...product.toJson(), if (imageId != null) 'imageUrl': imageId},
        );

        final updatedProduct = Product.fromJson(response.data);

        // Actualizar en SQLite
        await _localRepo.updateProduct(updatedProduct);

        // Actualizar en la lista local
        final index = products.indexWhere((p) => p.id == updatedProduct.id);
        if (index != -1) {
          products[index] = updatedProduct;
        }
      } catch (e) {
        debugPrint('Error updating product in Appwrite: $e');
        // Si falla Appwrite, actualizar solo localmente
        final localProduct = product.copyWith(updatedAt: DateTime.now());
        await _localRepo.updateProduct(localProduct);

        final index = products.indexWhere((p) => p.id == localProduct.id);
        if (index != -1) {
          products[index] = localProduct;
        }
      }

      Get.back();
      Get.snackbar(
        'Éxito',
        'Producto actualizado correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo actualizar el producto: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProduct(Product product) async {
    try {
      isLoading.value = true;

      if (product.imageUrl != null) {
        final imageId = product.imageUrl!.split('/').last.split('?').first;
        try {
          await storage.deleteFile(
            bucketId: AppwriteConfig.productsBucketId,
            fileId: imageId,
          );
        } catch (e) {
          debugPrint('Error deleting product image: $e');
        }
      }

      try {
        // Eliminar de Appwrite
        await databases.deleteDocument(
          databaseId: AppwriteConfig.databaseId,
          collectionId: AppwriteConfig.productsCollectionId,
          documentId: product.id,
        );
      } catch (e) {
        debugPrint('Error deleting product from Appwrite: $e');
      }

      // Eliminar de SQLite
      await _localRepo.deleteProduct(product.id);

      // Actualizar la lista local
      products.removeWhere((p) => p.id == product.id);
      Get.back();

      Get.snackbar(
        'Éxito',
        'Producto eliminado correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo eliminar el producto: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProductStock(String productId, int newStock) async {
    try {
      // Validación inicial
      if (newStock < 0) {
        throw 'El stock no puede ser negativo';
      }

      // Obtener el producto actual para mantener los demás datos
      final currentProduct = products.firstWhere((p) => p.id == productId);

      // Actualizar en la base de datos manteniendo los demás campos
      await databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.productsCollectionId,
        documentId: productId,
        data: {...currentProduct.toJson(forAppwrite: true), 'stock': newStock},
      );

      // Actualizar en la lista local
      final index = products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        final product = products[index];
        final updatedProduct = product.copyWith(stock: newStock);
        final updatedList = [...products];
        updatedList[index] = updatedProduct;
        products.value = updatedList;
      }

      // Para depuración
      debugPrint('Stock actualizado correctamente. Nuevo stock: $newStock');
    } catch (e) {
      debugPrint('Error actualizando stock del producto $productId: $e');
      throw 'No se pudo actualizar el stock del producto: ${e.toString()}';
    }
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    filterProducts();
  }

  void setSelectedCategory(String category) {
    selectedCategory.value = category;
    filterProducts();
  }

  Future<List<Product>> _getAllProducts() async {
    try {
      final userId = currentUser.value?.id;
      if (userId == null) {
        throw 'Usuario no autenticado';
      }

      final response = await databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.productsCollectionId,
        queries: [Query.equal('userId', userId)],
      );

      return response.documents
          .map((doc) => Product.fromJson(doc.data))
          .toList();
    } catch (e) {
      debugPrint('Error obteniendo productos: $e');
      return [];
    }
  }

  void filterProducts() async {
    try {
      isLoading.value = true;

      // Si no hay filtros activos, mostrar todos los productos
      if (searchQuery.value.isEmpty && selectedCategory.value.isEmpty) {
        final allProducts = await _getAllProducts();
        products.value = allProducts;
        return;
      }

      // Obtener todos los productos y filtrar localmente
      final allProducts = await _getAllProducts();

      products.value =
          allProducts.where((product) {
            final matchesSearch =
                searchQuery.value.isEmpty ||
                product.name.toLowerCase().contains(
                  searchQuery.value.toLowerCase(),
                );
            final matchesCategory =
                selectedCategory.value.isEmpty ||
                product.category == selectedCategory.value;
            return matchesSearch && matchesCategory;
          }).toList();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al filtrar productos: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  List<String> getUniqueCategories() {
    final categories = products.map((p) => p.category).toSet().toList()..sort();
    return categories;
  }
}
