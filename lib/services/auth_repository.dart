import 'package:appwrite/models.dart';
import '../data/providers/appwrite_provider.dart';

class AuthRepository {
  final AppwriteProvider _appwrite;

  AuthRepository({required AppwriteProvider appwrite}) : _appwrite = appwrite;

  Future<User> signUp(Map<String, dynamic> data) async {
    return await _appwrite.createUser(data);
  }

  Future<Session> login(String email, String password) async {
    return await _appwrite.createSession(email, password);
  }

  Future<void> logout(String sessionId) async {
    await _appwrite.deleteSession(sessionId);
  }

  Future<User> getCurrentUser() async {
    return await _appwrite.getCurrentUser();
  }
}
