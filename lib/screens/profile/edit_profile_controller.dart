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

  Future<void> updateProfile() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      // Actualizar nombre
      await account.updateName(name: nameController.text);

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

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}
