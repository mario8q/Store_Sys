import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_repository.dart';
import '../../utils/custom_snackbar.dart';
import '../../utils/full_screen_loader.dart';

class LoginController extends GetxController {
  final AuthRepository _authRepository;
  LoginController({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final formKey = GlobalKey<FormState>();
  final RxString email = ''.obs;
  final RxString password = ''.obs;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    emailController.addListener(() => email.value = emailController.text);
    passwordController.addListener(
      () => password.value = passwordController.text,
    );
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese su email';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Por favor ingrese un email válido';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese su contraseña';
    }
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    return null;
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    try {
      FullScreenLoader.showDialog();

      // Crear sesión
      final session = await _authRepository.login(email.value, password.value);

      // Verificar que podemos obtener los datos del usuario
      final user = await _authRepository.getCurrentUser();

      // Guardar datos importantes en storage
      final storage = GetStorage();
      await storage.write('userId', user.$id);
      await storage.write('sessionId', session.$id);

      FullScreenLoader.cancelDialog();

      CustomSnackbar.showSuccess(
        title: 'Éxito',
        message: 'Inicio de sesión exitoso',
      );

      // Navegar a la pantalla de inventario después del login exitoso
      await Get.offAllNamed(Routes.inventory);
    } catch (e) {
      FullScreenLoader.cancelDialog();
      CustomSnackbar.showError(
        title: 'Error',
        message: 'Credenciales inválidas',
      );
    }
  }

  void moveToSignUp() {
    Get.toNamed(Routes.signup);
  }

  @override
  void onClose() {
    if (!Get.isRegistered<LoginController>()) return;
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
