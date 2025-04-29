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

  // Variables reactivas para los valores
  final RxString email = ''.obs;
  final RxString password = ''.obs;

  // Controladores como late final
  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
    passwordController = TextEditingController();

    // Escuchar cambios en los controladores
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
    if (formKey.currentState!.validate()) {
      try {
        FullScreenLoader.showDialog();
        final session = await _authRepository.login(
          email.value,
          password.value,
        );

        final storage = GetStorage();
        storage.write('userId', session.userId);
        storage.write('sessionId', session.$id);

        FullScreenLoader.cancelDialog();
        CustomSnackbar.showSuccess(
          title: 'Éxito',
          message: 'Inicio de sesión exitoso',
        );

        await Get.offAllNamed(Routes.home);
      } catch (e) {
        FullScreenLoader.cancelDialog();
        CustomSnackbar.showError(
          title: 'Error',
          message: 'Credenciales inválidas',
        );
      }
    }
  }

  void moveToSignUp() {
    Get.toNamed(Routes.signup);
  }

  @override
  void onClose() {
    // Verificar que el controlador aún está registrado antes de hacer dispose
    if (!Get.isRegistered<LoginController>()) {
      return;
    }
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
