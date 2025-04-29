import 'package:appwrite/appwrite.dart';
import 'package:get/get.dart';
import '../models/product.dart';
import '../../config/appwrite_config.dart';

class InventoryProvider {
  final Databases _databases;
  final Storage _storage;

  InventoryProvider()
      : _databases = Databases(Get.find<Client>()),
        _storage = Storage(Get.find<Client>());

  Future<List<Product>> getProducts() async {
    try {
      final response = await _databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.productsCollectionId,
      );

      return response.documents.map((doc) => Product.fromJson(doc.data)).toList();
    } catch (e) {
      throw 'Error al obtener productos: $e';
    }
  }

  Future<Product> createProduct(Product product, {String? imagePath}) async {
    try {
      String? imageUrl;
      if (imagePath != null) {
        final file = await _storage.createFile(
          bucketId: AppwriteConfig.productsBucketId,
          fileId: ID.unique(),
          file: InputFile.fromPath(path: imagePath),
        );
        imageUrl = file.$id;
      }

      final response = await _databases.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.productsCollectionId,
        documentId: ID.unique(),
        data: {
          ...product.toJson(),
          if (imageUrl != null) 'imageUrl': imageUrl,
        },
      );

      return Product.fromJson(response.data);
    } catch (e) {
      throw 'Error al crear producto: $e';
    }
  }

  Future<Product> updateProduct(Product product, {String? imagePath}) async {
    try {
      String? imageUrl = product.imageUrl;
      if (imagePath != null) {
        if (imageUrl != null) {
          await _storage.deleteFile(
            bucketId: AppwriteConfig.productsBucketId,
            fileId: imageUrl,
          );
        }
        final file = await _storage.createFile(
          bucketId: AppwriteConfig.productsBucketId,
          fileId: ID.unique(),
          file: InputFile.fromPath(path: imagePath),
        );
        imageUrl = file.$id;
      }

      final response = await _databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.productsCollectionId,
        documentId: product.id,
        data: {
          ...product.toJson(),
          if (imageUrl != null) 'imageUrl': imageUrl,
        },
      );

      return Product.fromJson(response.data);
    } catch (e) {
      throw 'Error al actualizar producto: $e';
    }
  }

  Future<void> deleteProduct(String productId, {String? imageUrl}) async {
    try {
      if (imageUrl != null) {
        await _storage.deleteFile(
          bucketId: AppwriteConfig.productsBucketId,
          fileId: imageUrl,
        );
      }

      await _databases.deleteDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.productsCollectionId,
        documentId: productId,
      );
    } catch (e) {
      throw 'Error al eliminar producto: $e';
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.productsCollectionId,
        queries: [
          Query.search('name', query),
        ],
      );

      return response.documents.map((doc) => Product.fromJson(doc.data)).toList();
    } catch (e) {
      throw 'Error al buscar productos: $e';
    }
  }
}