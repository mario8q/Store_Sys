import '../../config/appwrite_config.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? password; // Optional para cuando se obtiene de Appwrite

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': id,
      'name': name,
      'email': email,
      if (password != null) 'password': password,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id:
          json['\$id'] ??
          json['userId'] ??
          '', // Maneja tanto \$id de Appwrite como userId
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'], // Opcional
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}
