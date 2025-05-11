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

class InventoryController extends GetxController {
  final client = Get.find<Client>();
  late final Account account;
  late final Databases databases;
  late final Storage storage;
  final AuthRepository _authRepository;

  final RxList<Product> products = <Product>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCategory = ''.obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  InventoryController({required AuthRepository authRepository})
    : _authRepository = authRepository;

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
      final allProducts = await _getAllProducts();
      products.value = allProducts;

      // Si hay filtros activos, aplicarlos
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

      // Si hay una imagen, súbela primero
      if (image != null) {
        final file = await storage.createFile(
          bucketId: AppwriteConfig.productsBucketId,
          fileId: ID.unique(),
          file: InputFile.fromPath(path: image.path),
        );
        imageId = file.$id;
      }

      // Crear el documento del producto con el userId
      final productWithUserId = product.copyWith(userId: userId);
      final response = await databases.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.productsCollectionId,
        documentId: ID.unique(),
        data: {
          ...productWithUserId.toJson(),
          if (imageId != null) 'imageUrl': imageId,
        },
      );

      final newProduct = Product.fromJson(response.data);
      products.add(newProduct);

      Get.snackbar(
        'Éxito',
        'Producto creado correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
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

      // Si hay una nueva imagen, súbela primero
      if (image != null) {
        final file = await storage.createFile(
          bucketId: AppwriteConfig.productsBucketId,
          fileId: ID.unique(),
          file: InputFile.fromPath(path: image.path),
        );
        imageId = file.$id;
      }

      // Actualizar el documento del producto
      final response = await databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.productsCollectionId,
        documentId: product.id,
        data: {...product.toJson(), if (imageId != null) 'imageUrl': imageId},
      );

      final updatedProduct = Product.fromJson(response.data);
      final index = products.indexWhere((p) => p.id == updatedProduct.id);
      if (index != -1) {
        products[index] = updatedProduct;
      } // Actualizar UI primero, luego mostrar mensaje
      Get.back(); // Volver a la pantalla de inventario
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

      // Si el producto tiene una imagen, eliminarla primero
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

      // Eliminar el documento del producto
      await databases.deleteDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.productsCollectionId,
        documentId: product.id,
      );

      products.removeWhere((p) => p.id == product.id);
      Get.back(); // Volver a la pantalla de inventario

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
