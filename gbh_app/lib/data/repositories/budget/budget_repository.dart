import 'package:marshmellow/data/datasources/remote/budget/budget_api.dart';
import 'package:marshmellow/data/models/budget/budget_model.dart';

class BudgetRepository {
  final BudgetApi _budgetApi;

  BudgetRepository(this._budgetApi);

  // 전체 예산 조회
  Future<List<BudgetModel>> getAllBudgets() async {
    return await _budgetApi.getAllBudgets();
  }
  
  // 세부 예산 조회
  Future<List<BudgetCategoryModel>> getBudgetDetail(int budgetPk) async {
    return await _budgetApi.getBudgetDetail(budgetPk);
  }
  
  // 세부 예산 수정
  Future<Map<String, dynamic>> updateBudgetCategory(int budgetCategoryPk, int budgetAmount) async {
    return await _budgetApi.updateBudgetCategory(budgetCategoryPk, budgetAmount);
  }

  // 오늘의 예산 조회  
  Future<DailyBudgetModel> getDailyBudget() async {
    return await _budgetApi.getDailyBudget();
  }
  
  // 예산 알림 시간 수정
  Future<Map<String, dynamic>> updateBudgetAlarm(String alarmTime) async {
    return await _budgetApi.updateBudgetAlarm(alarmTime);
  }

  // 예산 생성
  Future<Map<String, dynamic>> createBudget({
    required int salary,
    required double fixedExpense,
    required double foodExpense,
    required double transportationExpense,
    required double marketExpense,
    required double financialExpense,
    required double leisureExpense,
    required double coffeeExpense,
    required double shoppingExpense,
    required double emergencyExpense,
  }) async {
    print('📊 Repository: 예산 생성 요청');
    final budgetData = {
      'salary': salary,
      'fixedExpense': fixedExpense,
      'foodExpense': foodExpense,
      'transportationExpense': transportationExpense,
      'marketExpense': marketExpense,
      'financialExpense': financialExpense,
      'leisureExpense': leisureExpense,
      'coffeeExpense': coffeeExpense,
      'shoppingExpense': shoppingExpense,
      'emergencyExpense': emergencyExpense,
    };
    print('📊 Request Body: $budgetData');

    return await _budgetApi.createBudget(budgetData);
  }
}