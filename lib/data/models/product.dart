import 'package:flutter/foundation.dart';
import '../../config/appwrite_config.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String? imageUrl;
  final String category;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    this.imageUrl,
    required this.category,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });
  factory Product.fromJson(Map<String, dynamic> json) {
    String? imageId = json['imageUrl'];
    String? imageUrl;
    if (imageId != null) {
      imageUrl =
          '${AppwriteConfig.endpoint}/storage/buckets/${AppwriteConfig.productsBucketId}/files/$imageId/view?project=${AppwriteConfig.projectId}';
      debugPrint('URL de imagen construida: $imageUrl');
    }

    return Product(
      id: json['\$id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      stock: json['stock'] ?? 0,
      imageUrl: imageUrl,
      category: json['category'] ?? '',
      userId: json['userId'] ?? '',
      createdAt: DateTime.parse(json['\$createdAt']),
      updatedAt: DateTime.parse(json['\$updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'category': category,
      'userId': userId,
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    int? stock,
    String? imageUrl,
    String? category,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
