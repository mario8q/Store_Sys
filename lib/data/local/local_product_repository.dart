import '../models/product.dart';
import 'database_helper.dart';
import 'package:sqflite/sqflite.dart';

class LocalProductRepository {
  final dbHelper = DatabaseHelper.instance;
  Future<void> saveProduct(Product product) async {
    final db = await dbHelper.database;
    await db.insert(
      'products',
      product.toJson(forAppwrite: false),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> saveProducts(List<Product> products) async {
    final db = await dbHelper.database;
    final batch = db.batch();

    for (var product in products) {
      batch.insert(
        'products',
        product.toJson(forAppwrite: false),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<List<Product>> getProducts(String userId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    return List.generate(maps.length, (i) => Product.fromJson(maps[i]));
  }

  Future<Product?> getProduct(String id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'document_id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Product.fromJson(maps.first);
    }
    return null;
  }

  Future<void> deleteProduct(String id) async {
    final db = await dbHelper.database;
    await db.delete('products', where: 'document_id = ?', whereArgs: [id]);
  }

  Future<void> updateProduct(Product product) async {
    final db = await dbHelper.database;
    final data = product.toJson(forAppwrite: false);

    // Asegurarse de que la URL de la imagen se mantenga
    if (product.imageUrl != null) {
      data['imageUrl'] = product.imageUrl;
    }

    await db.update(
      'products',
      data,
      where: 'document_id = ?',
      whereArgs: [product.id],
    );
  }

  Future<void> clearProducts() async {
    final db = await dbHelper.database;
    await db.delete('products');
  }

  Future<void> resetDatabase() async {
    await dbHelper.deleteDB();
  }
}
