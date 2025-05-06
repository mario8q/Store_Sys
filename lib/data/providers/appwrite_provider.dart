import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:get/get.dart';
import '../../config/appwrite_config.dart';

class AppwriteProvider {
  final Client client;
  late final Account account;
  late final Databases databases;
  late final Storage storage;

  AppwriteProvider() : client = Get.find<Client>() {
    // Usar el cliente global que ya está configurado en main.dart
    account = Account(client);
    databases = Databases(client);
    storage = Storage(client);
  }

  Future<User> createUser(Map<String, dynamic> data) async {
    final response = await account.create(
      userId: data['userId'],
      email: data['email'],
      password: data['password'],
      name: data['name'],
    );
    return response;
  }

  Future<Session> createSession(String email, String password) async {
    final response = await account.createEmailPasswordSession(
      email: email,
      password: password,
    );
    return response;
  }

  Future<void> deleteSession(String sessionId) async {
    await account.deleteSession(sessionId: sessionId);
  }

  Future<User> getCurrentUser() async {
    return await account.get();
  }
}
