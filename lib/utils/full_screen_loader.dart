import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FullScreenLoader {
  static void showDialog() {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: const Center(child: CircularProgressIndicator()),
      ),
      barrierDismissible: false,
    );
  }

  static void cancelDialog() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
}
