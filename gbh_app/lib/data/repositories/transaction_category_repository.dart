import 'package:marshmellow/data/models/ledger/expense_category.dart';
import 'package:marshmellow/data/models/ledger/income_category.dart';
import 'package:marshmellow/data/models/ledger/transaction_category.dart';

class TransactionCategoryRepository {
  // 모든 지출 카테고리 가져오기
  List<ExpenseCategory> getExpenseCategories() {
    return ExpenseCategory.allCategories;
  }
  
  // 모든 수입 카테고리 가져오기
  List<IncomeCategory> getIncomeCategories() {
    return IncomeCategory.allCategories;
  }
  
  // 지출 카테고리 ID로 카테고리 정보 가져오기
  ExpenseCategory? getExpenseCategoryById(ExpenseCategoryType typeId) {
    try {
      return ExpenseCategory.getById(typeId);
    } catch (_) {
      return null;
    }
  }
  
  // 수입 카테고리 ID로 카테고리 정보 가져오기
  IncomeCategory? getIncomeCategoryById(IncomeCategoryType typeId) {
    try {
      return IncomeCategory.getById(typeId);
    } catch (_) {
      return null;
    }
  }
  
  // 트랜잭션 타입에 따라 모든 트랜잭션 카테고리 가져오기
  List<TransactionCategory> getTransactionCategories(TransactionType type) {
    switch (type) {
      case TransactionType.expense:
        return TransactionCategory.getAllExpenseCategories();
      case TransactionType.income:
        return TransactionCategory.getAllIncomeCategories();
    }
  }
  
  // 카테고리 이름으로 검색
  List<TransactionCategory> searchCategoriesByName(String query) {
    final allCategories = [
      ...getTransactionCategories(TransactionType.expense),
      ...getTransactionCategories(TransactionType.income),
    ];
    
    if (query.isEmpty) return allCategories;
    
    return allCategories
        .where((cat) => cat.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}