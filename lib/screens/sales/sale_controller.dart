import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/sale.dart';
import '../../data/providers/sale_provider.dart';
import '../../data/models/user_model.dart';
import '../inventory/inventory_controller.dart';

class SaleController extends GetxController {
  final SaleProvider _saleProvider = SaleProvider();
  final RxBool isLoading = false.obs;
  final RxList<Sale> sales = <Sale>[].obs;
  late final Rx<UserModel?> currentUser;

  // Para la pantalla de nueva venta
  final RxMap<String, int> selectedProducts = <String, int>{}.obs;
  final RxDouble currentTotal = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    currentUser = Get.find<InventoryController>().currentUser;
    fetchSales();
  }

  Future<void> fetchSales() async {
    try {
      if (currentUser.value == null) {
        throw 'Usuario no autenticado';
      }

      isLoading.value = true;
      final fetchedSales = await _saleProvider.getSales(currentUser.value!.id);
      sales.value = fetchedSales;
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron cargar las ventas: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createSale(DateTime date) async {
    try {
      if (currentUser.value == null) {
        throw 'Usuario no autenticado';
      }

      if (selectedProducts.isEmpty) {
        throw 'No hay productos seleccionados';
      }

      isLoading.value = true;

      // Verificar stock antes de proceder
      final inventoryController = Get.find<InventoryController>();
      for (final entry in selectedProducts.entries) {
        final product = inventoryController.products.firstWhere(
          (p) => p.id == entry.key,
        );
        if (product.stock < entry.value) {
          throw 'Stock insuficiente para ${product.name}';
        }
      }

      // Convertir el mapa de productos seleccionados a una lista de SaleItem
      final items =
          selectedProducts.entries.map((entry) {
            final product = inventoryController.products.firstWhere(
              (p) => p.id == entry.key,
            );
            return SaleItem(
              productId: product.id,
              productName: product.name,
              price: product.price,
              quantity: entry.value,
            );
          }).toList();

      final sale = Sale(
        id: '',
        items: items,
        date: date,
        userId: currentUser.value!.id,
      );

      // Crear la venta primero
      await _saleProvider.createSale(sale);

      // Si la venta se creó exitosamente, actualizar el stock
      bool stockUpdateError = false;
      String errorMessage = '';
      try {
        // Actualizar el stock de los productos uno por uno con manejo de errores individual
        for (final entry in selectedProducts.entries) {
          try {
            debugPrint('Procesando producto ${entry.key}');
            final product = inventoryController.products.firstWhere(
              (p) => p.id == entry.key,
            );
            final newStock = product.stock - entry.value;

            if (newStock < 0) {
              throw 'Stock insuficiente para ${product.name}';
            }

            debugPrint(
              'Actualizando stock de ${product.name} de ${product.stock} a $newStock',
            );
            await inventoryController.updateProductStock(product.id, newStock);

            // Forzar una actualización del controlador de inventario
            await inventoryController.fetchProducts();

            // Verificar que se actualizó correctamente
            final updatedProduct = inventoryController.products.firstWhere(
              (p) => p.id == entry.key,
            );
            debugPrint(
              'Stock actualizado para ${updatedProduct.name}: ${updatedProduct.stock}',
            );
          } catch (productError) {
            debugPrint(
              'Error al actualizar producto ${entry.key}: $productError',
            );
            stockUpdateError = true;
            errorMessage +=
                '${errorMessage.isEmpty ? "" : "\n"}Error con producto ${entry.key}: $productError';
          }
        }

        if (stockUpdateError) {
          debugPrint(
            'Algunos productos no se pudieron actualizar: $errorMessage',
          );
        }
      } catch (e) {
        stockUpdateError = true;
        errorMessage = 'Error general actualizando stock: ${e.toString()}';
        debugPrint('Error general actualizando stock: $e');
      }

      // Si hubo error actualizando el stock, notificar pero no impedir la venta
      if (stockUpdateError) {
        Get.snackbar(
          'Advertencia',
          'La venta se registró pero hubo un error actualizando el inventario: $errorMessage\nPor favor, actualice el stock manualmente.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      } else {
        Get.snackbar(
          'Éxito',
          'Venta registrada correctamente',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }

      // Limpiar selección y total
      selectedProducts.clear();
      currentTotal.value = 0;

      Get.back(); // Volver a la lista de ventas
      fetchSales(); // Actualizar la lista
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo registrar la venta: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteSale(String saleId) async {
    try {
      isLoading.value = true;
      await _saleProvider.deleteSale(saleId);
      sales.removeWhere((s) => s.id == saleId);
      Get.snackbar(
        'Éxito',
        'Venta eliminada correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo eliminar la venta: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void updateProductQuantity(String productId, bool increment) {
    final product = Get.find<InventoryController>().products.firstWhere(
      (p) => p.id == productId,
    );
    final currentQuantity = selectedProducts[productId] ?? 0;

    if (increment) {
      if (currentQuantity < product.stock) {
        // Create a new map to trigger reactivity
        final newMap = Map<String, int>.from(selectedProducts);
        newMap[productId] = currentQuantity + 1;
        selectedProducts.value = newMap;
        updateTotal();
      } else {
        Get.snackbar(
          'Advertencia',
          'No hay más stock disponible de este producto',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } else {
      if (currentQuantity > 0) {
        // Create a new map to trigger reactivity
        final newMap = Map<String, int>.from(selectedProducts);
        if (currentQuantity == 1) {
          newMap.remove(productId);
        } else {
          newMap[productId] = currentQuantity - 1;
        }
        selectedProducts.value = newMap;
        updateTotal();
      }
    }
  }

  void updateTotal() {
    double total = 0;
    for (final entry in selectedProducts.entries) {
      final product = Get.find<InventoryController>().products.firstWhere(
        (p) => p.id == entry.key,
      );
      total += product.price * entry.value;
    }
    currentTotal.value = total;
  }
}
