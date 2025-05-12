import 'package:flutter/foundation.dart';
import 'product.dart';

class SaleItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;

  SaleItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
  });

  double get total => price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
    };
  }

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      productId: json['productId'],
      productName: json['productName'],
      price: double.parse(json['price'].toString()),
      quantity: json['quantity'],
    );
  }
}

class Sale {
  final String id;
  final List<SaleItem> items;
  final DateTime date;
  final String userId;
  final double total;
  final DateTime createdAt;

  Sale({
    required this.id,
    required this.items,
    required this.date,
    required this.userId,
    DateTime? createdAt,
  }) : this.total = items.fold(0, (sum, item) => sum + item.total),
       this.createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    // Separar los items en arrays paralelos para Appwrite
    final productIds = items.map((item) => item.productId).toList();
    final productNames = items.map((item) => item.productName).toList();
    final prices = items.map((item) => item.price).toList();
    final quantities = items.map((item) => item.quantity).toList();

    return {
      'date': date.toIso8601String(),
      'userId': userId,
      'total': total,
      'productIds': productIds,
      'productNames': productNames,
      'prices': prices,
      'quantities': quantities,
    };
  }

  factory Sale.fromJson(Map<String, dynamic> json) {
    // Reconstruir los items desde los arrays paralelos
    final productIds = List<String>.from(json['productIds']);
    final productNames = List<String>.from(json['productNames']);
    final prices = List<double>.from(
      json['prices'].map((p) => double.parse(p.toString())),
    );
    final quantities = List<int>.from(json['quantities']);

    final items = List.generate(
      productIds.length,
      (i) => SaleItem(
        productId: productIds[i],
        productName: productNames[i],
        price: prices[i],
        quantity: quantities[i],
      ),
    );

    return Sale(
      id: json['\$id'] ?? '',
      items: items,
      date: DateTime.parse(json['date']),
      userId: json['userId'],
      createdAt:
          json['\$createdAt'] != null
              ? DateTime.parse(json['\$createdAt'])
              : null,
    );
  }
}
