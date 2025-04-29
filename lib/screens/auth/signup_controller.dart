import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:appwrite/appwrite.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_repository.dart';
import '../../utils/custom_snackbar.dart';
import '../../utils/full_screen_loader.dart';

class SignUpController extends GetxController {
  final AuthRepository _authRepository;
  SignUpController({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final formKey = GlobalKey<FormState>();

  // Usar RxString para manejar los valores de forma reactiva
  final RxString name = ''.obs;
  final RxString email = ''.obs;
  final RxString password = ''.obs;

  // Los controladores ahora son late final para asegurar que se inicializan una sola vez
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  @override
  void onInit() {
    super.onInit();
    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();

    // Escuchar cambios en los controladores
    nameController.addListener(() => name.value = nameController.text);
    emailController.addListener(() => email.value = emailController.text);
    passwordController.addListener(
      () => password.value = passwordController.text,
    );
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese su nombre';
    }
    return null;
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

  Future<void> signUp() async {
    if (formKey.currentState!.validate()) {
      try {
        FullScreenLoader.showDialog();

        final userData = {
          'userId': ID.unique(),
          'email': email.value,
          'password': password.value,
          'name': name.value,
        };

        await _authRepository.signUp(userData);

        FullScreenLoader.cancelDialog();

        CustomSnackbar.showSuccess(
          title: 'Éxito',
          message: 'Cuenta creada exitosamente',
        );

        await Get.offAllNamed(Routes.login);
      } catch (e) {
        FullScreenLoader.cancelDialog();
        CustomSnackbar.showError(
          title: 'Error',
          message:
              e is AppwriteException
                  ? e.message ?? 'Error al crear la cuenta'
                  : 'Error al crear la cuenta',
        );
      }
    }
  }

  @override
  void onClose() {
    // Asegurarnos de que los controladores estén disponibles antes de hacer dispose
    if (!Get.isRegistered<SignUpController>()) {
      return;
    }
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
