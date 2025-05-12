import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:appwrite/appwrite.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'config/appwrite_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Configurar el cliente de Appwrite con la configuración correcta
  final client = Client();
  client
    ..setEndpoint(AppwriteConfig.endpoint)
    ..setProject(AppwriteConfig.projectId);
  // Removido setSelfSigned ya que estamos usando cloud.appwrite.io

  // Registrar el cliente como una dependencia global
  Get.put<Client>(client, permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'StorSys',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.splash,
      getPages: AppPages.pages,
    );
  }
}
