import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import '../../utils/appwrite_constants.dart';

class AppwriteProvider {
  Client client = Client();
  late final Account account;
  late final Databases databases;
  late final Storage storage;

  AppwriteProvider() {
    client
        .setEndpoint(AppwriteConstants.endpoint)
        .setProject(AppwriteConstants.projectId)
        .setSelfSigned(status: true); // For development only

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
}
