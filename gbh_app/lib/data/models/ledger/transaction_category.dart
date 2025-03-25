import 'package:marshmellow/data/models/ledger/expense_category.dart';
import 'package:marshmellow/data/models/ledger/income_category.dart';

enum TransactionType {
  expense,
  income,
}

class TransactionCategory {
  final TransactionType type;
  final dynamic categoryId; // ExpenseCategoryType 또는 IncomeCategoryType
  final String name;
  final String iconPath;

  TransactionCategory({
    required this.type,
    required this.categoryId,
    required this.name,
    required this.iconPath,
  });

  // 지출 카테고리로부터 변환
  factory TransactionCategory.fromExpense(ExpenseCategory category) {
    return TransactionCategory(
      type: TransactionType.expense,
      categoryId: category.type,
      name: category.name,
      iconPath: category.iconPath,
    );
  }

  // 수입 카테고리로부터 변환
  factory TransactionCategory.fromIncome(IncomeCategory category) {
    return TransactionCategory(
      type: TransactionType.income,
      categoryId: category.type,
      name: category.name,
      iconPath: category.iconPath,
    );
  }

  // 모든 지출 카테고리 가져오기
  static List<TransactionCategory> getAllExpenseCategories() {
    return ExpenseCategory.allCategories
        .map((e) => TransactionCategory.fromExpense(e))
        .toList();
  }

  // 모든 수입 카테고리 가져오기
  static List<TransactionCategory> getAllIncomeCategories() {
    return IncomeCategory.allCategories
        .map((e) => TransactionCategory.fromIncome(e))
        .toList();
  }
}
