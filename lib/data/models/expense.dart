import 'package:flutter/foundation.dart';

class Expense {
  final String id;
  final DateTime date;
  final String category;
  final double amount;
  final String paymentMethod;
  final String description;
  final String userId;
  final DateTime createdAt;
  Expense({
    required this.id,
    required this.date,
    required this.category,
    required this.amount,
    required this.paymentMethod,
    required this.description,
    required this.userId,
    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();

  static const List<String> categories = [
    'Servicios publicos',
    'Compra de productos e insumos',
    'Muebles o maquinaria',
    'Otros',
  ];

  static const List<String> paymentMethods = [
    'Efectivo',
    'Tarjeta',
    'Transferencia',
    'Otro',
  ];
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['\$id'] ?? '',
      date: DateTime.parse(json['date']),
      category: json['category'] ?? '',
      amount: double.parse(json['amount'].toString()),
      paymentMethod: json['paymentMethod'] ?? '',
      description: json['description'] ?? '',
      userId: json['userId'] ?? '',
      createdAt:
          json['\$createdAt'] != null
              ? DateTime.parse(json['\$createdAt'])
              : DateTime.now(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'category': category,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'description': description,
      'userId': userId,
    };
  }
}
