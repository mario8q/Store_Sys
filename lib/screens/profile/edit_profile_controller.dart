import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:appwrite/appwrite.dart';
import '../../data/models/user_model.dart';
import '../inventory/inventory_controller.dart';

class EditProfileController extends GetxController {
  final client = Get.find<Client>();
  late final Account account;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    account = Account(client);
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      isLoading.value = true;
      final response = await account.get();
      currentUser.value = UserModel.fromJson(response.toMap());
      nameController.text = currentUser.value?.name ?? '';
      emailController.text = currentUser.value?.email ?? '';
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo cargar la información del usuario',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
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

  Future<void> updateProfile() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      // Actualizar nombre
      await account.updateName(name: nameController.text);

      // Actualizar email si ha cambiado
      if (emailController.text != currentUser.value?.email) {
        final password = await _showPasswordDialog();
        if (password != null) {
          await account.updateEmail(
            email: emailController.text,
            password: password,
          );
        }
      }

      Get.snackbar(
        'Éxito',
        'Perfil actualizado correctamente',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      await loadUserData();

      // Notificar al InventoryController para actualizar el drawer
      final inventoryController = Get.find<InventoryController>();
      await inventoryController.loadUserData();

      Get.back(); // Volver a la pantalla anterior
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo actualizar el perfil: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> _showPasswordDialog() async {
    final passwordController = TextEditingController();

    return await Get.dialog<String>(
      AlertDialog(
        title: const Text('Confirmar cambio de email'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Para cambiar tu email, necesitamos verificar tu identidad.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Contraseña actual',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              if (passwordController.text.isNotEmpty) {
                Get.back(result: passwordController.text);
              }
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    super.onClose();
  }
}
