import 'package:get/get.dart';
import 'app_routes.dart';
import '../screens/splash/splash_binding.dart';
import '../screens/splash/splash_view.dart';
import '../screens/auth/login_binding.dart';
import '../screens/auth/login_view.dart';
import '../screens/auth/signup_binding.dart';
import '../screens/auth/signup_view.dart';
import '../screens/inventory/inventory_binding.dart';
import '../screens/inventory/inventory_screen.dart';
import '../screens/inventory/create_product_screen.dart';
import '../screens/inventory/product_detail_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/edit_profile_binding.dart';
import '../screens/expenses/create_expense_screen.dart';
import '../screens/expenses/expense_list_screen.dart';
import '../screens/expenses/expense_binding.dart';
import '../screens/sales/sale_list_screen.dart';
import '../screens/sales/create_sale_screen.dart';
import '../screens/sales/sale_binding.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.signup,
      page: () => const SignUpView(),
      binding: SignUpBinding(),
    ),
    GetPage(
      name: Routes.inventory,
      page: () => const InventoryScreen(),
      binding: InventoryBinding(),
    ),
    GetPage(
      name: Routes.createProduct,
      page: () => const CreateProductScreen(),
    ),
    GetPage(
      name: Routes.productDetail,
      page: () => const ProductDetailScreen(),
    ),
    GetPage(
      name: Routes.editProfile,
      page: () => const EditProfileScreen(),
      binding: EditProfileBinding(),
    ),
    GetPage(
      name: Routes.expenseList,
      page: () => const ExpenseListScreen(),
      binding: ExpenseBinding(),
      children: [
        GetPage(
          name: Routes.createExpense,
          page: () => const CreateExpenseScreen(),
        ),
      ],
    ),
    GetPage(
      name: Routes.saleList,
      page: () => const SaleListScreen(),
      binding: SaleBinding(),
      children: [
        GetPage(name: Routes.createSale, page: () => const CreateSaleScreen()),
      ],
    ),
  ];
}
