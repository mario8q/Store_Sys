import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:appwrite/appwrite.dart';
import '../../routes/app_routes.dart';

class SplashController extends GetxController {
  final _storage = GetStorage();
  final client = Get.find<Client>();
  late final Account account;

  @override
  void onInit() {
    super.onInit();
    account = Account(client);
  }

  @override
  void onReady() {
    super.onReady();
    _checkAuth();
  }

  void _checkAuth() async {
    try {
      await Future.delayed(const Duration(seconds: 3));

      // Intenta obtener la sesión actual
      await account.get();

      // Si no hay error, la sesión es válida
      Get.offAllNamed(Routes.inventory);
    } catch (e) {
      // Si hay error, la sesión no es válida o expiró
      await _storage.erase(); // Limpia el almacenamiento local
      Get.offAllNamed(Routes.login);
    }
  }
}
