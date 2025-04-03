import 'package:marshmellow/data/datasources/remote/budget_api.dart';
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
}