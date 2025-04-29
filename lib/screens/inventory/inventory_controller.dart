import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/product.dart';
import '../../data/providers/inventory_provider.dart';

class InventoryController extends GetxController {
  final InventoryProvider _inventoryProvider = InventoryProvider();
  final _products = <Product>[].obs;
  final _isLoading = false.obs;
  final _searchQuery = ''.obs;
  final _selectedCategory = RxString('');
  
  bool get isLoading => _isLoading.value;
  List<Product> get products => _products;
  String get searchQuery => _searchQuery.value;
  String get selectedCategory => _selectedCategory.value;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      _isLoading.value = true;
      final products = await _inventoryProvider.getProducts();
      _products.assignAll(products);
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron cargar los productos: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> createProduct(Product product, {XFile? imageFile}) async {
    try {
      _isLoading.value = true;
      await _inventoryProvider.createProduct(
        product,
        imagePath: imageFile?.path,
      );
      await fetchProducts();
      Get.back();
      Get.snackbar(
        'Éxito',
        'Producto creado correctamente',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo crear el producto: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateProduct(Product product, {XFile? imageFile}) async {
    try {
      _isLoading.value = true;
      await _inventoryProvider.updateProduct(
        product,
        imagePath: imageFile?.path,
      );
      await fetchProducts();
      Get.back();
      Get.snackbar(
        'Éxito',
        'Producto actualizado correctamente',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo actualizar el producto: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> deleteProduct(Product product) async {
    try {
      _isLoading.value = true;
      await _inventoryProvider.deleteProduct(
        product.id,
        imageUrl: product.imageUrl,
      );
      await fetchProducts();
      Get.snackbar(
        'Éxito',
        'Producto eliminado correctamente',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo eliminar el producto: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  void setSearchQuery(String query) {
    _searchQuery.value = query;
    filterProducts();
  }

  void setSelectedCategory(String category) {
    _selectedCategory.value = category;
    filterProducts();
  }

  Future<void> filterProducts() async {
    try {
      _isLoading.value = true;
      if (_searchQuery.value.isEmpty && _selectedCategory.value.isEmpty) {
        await fetchProducts();
        return;
      }

      final List<Product> filteredProducts = await _inventoryProvider.searchProducts(_searchQuery.value);
      
      if (_selectedCategory.value.isNotEmpty) {
        _products.assignAll(
          filteredProducts.where((p) => p.category == _selectedCategory.value),
        );
      } else {
        _products.assignAll(filteredProducts);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al filtrar productos: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }
}