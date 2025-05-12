import 'package:appwrite/appwrite.dart';
import 'package:get/get.dart';
import '../../config/appwrite_config.dart';
import '../models/sale.dart';

class SaleProvider {
  final Databases _databases;

  SaleProvider() : _databases = Databases(Get.find<Client>());

  Future<List<Sale>> getSales(String userId) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.salesCollectionId,
        queries: [Query.equal('userId', userId)],
      );

      return response.documents.map((doc) => Sale.fromJson(doc.data)).toList();
    } catch (e) {
      throw 'Error al obtener ventas: $e';
    }
  }

  Future<Sale> createSale(Sale sale) async {
    try {
      final response = await _databases.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.salesCollectionId,
        documentId: ID.unique(),
        data: sale.toJson(),
      );

      return Sale.fromJson(response.data);
    } catch (e) {
      throw 'Error al crear venta: $e';
    }
  }

  Future<void> deleteSale(String saleId) async {
    try {
      await _databases.deleteDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.salesCollectionId,
        documentId: saleId,
      );
    } catch (e) {
      throw 'Error al eliminar venta: $e';
    }
  }
}
