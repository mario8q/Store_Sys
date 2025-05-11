import 'package:appwrite/appwrite.dart';
import 'package:get/get.dart';
import '../../config/appwrite_config.dart';
import '../models/expense.dart';

class ExpenseProvider {
  final Databases _databases;

  ExpenseProvider() : _databases = Databases(Get.find<Client>());

  Future<List<Expense>> getExpenses(String userId) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.expensesCollectionId,
        queries: [Query.equal('userId', userId)],
      );

      return response.documents
          .map((doc) => Expense.fromJson(doc.data))
          .toList();
    } catch (e) {
      throw 'Error al obtener gastos: $e';
    }
  }

  Future<Expense> createExpense(Expense expense) async {
    try {
      final response = await _databases.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.expensesCollectionId,
        documentId: ID.unique(),
        data: expense.toJson(),
      );

      return Expense.fromJson(response.data);
    } catch (e) {
      throw 'Error al crear gasto: $e';
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    try {
      await _databases.deleteDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.expensesCollectionId,
        documentId: expenseId,
      );
    } catch (e) {
      throw 'Error al eliminar gasto: $e';
    }
  }
}
