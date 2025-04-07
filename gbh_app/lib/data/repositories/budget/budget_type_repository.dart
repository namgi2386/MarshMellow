import 'package:marshmellow/data/datasources/remote/budget/budget_type_api.dart';
import 'package:marshmellow/data/models/budget/budget_type_model.dart';

class BudgetTypeRepository {
  final BudgetTypeApi _budgetTypeApi;

  BudgetTypeRepository(this._budgetTypeApi);

  // 예산 유형 분석
  Future<BudgetTypeAnalysisResponse> analyzeBudgetType(BudgetTypeAnalysisRequest request) async {
    return await _budgetTypeApi.analyzeBudgetType(request);
  }

  // request body 더미
  Future<BudgetTypeAnalysisResponse> analyzeWithDummyData() async {
    final dummyRequest = BudgetTypeAnalysisRequest(
      salary: 3000000,
      fixedExpense: 0.2,
      foodExpense: 0.7,
      transportationExpense: 0.2,
      marketExpense: 0.2,
      financialExpense: 0.6,
      leisureExpense: 0.2,
      coffeeExpense: 0.1,
      shoppingExpense: 0.2,
      emergencyExpense: 0.1,
    );
    return await _budgetTypeApi.analyzeBudgetType(dummyRequest);
  }

  // 예산 유형 선택 저장
  Future<bool> saveBudgetTypeSelection(String selectedType) async {
    // 사용자가 선택한 예산 유형을 저장하는 것을 여기에 작성해!!!
    return true;
  }
}