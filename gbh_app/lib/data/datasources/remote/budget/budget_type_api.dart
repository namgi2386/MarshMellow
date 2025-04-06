import 'package:marshmellow/data/datasources/remote/api_client.dart';
import 'package:marshmellow/data/models/budget/budget_type_model.dart';

class BudgetTypeApi {
  final ApiClient _apiClient;

  BudgetTypeApi(this._apiClient);

  // 예산 유형별 분석 api 호출
  Future<BudgetTypeAnalysisResponse> analyzeBudgetType(BudgetTypeAnalysisRequest request) async {
    try {
      final response = await _apiClient.post(
        '/mm/ai/type',
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return BudgetTypeAnalysisResponse.fromJson(data);
      } else {
        throw Exception('Failed to load budget type analysis data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load budget type analysis data: $e');
    }
  }

  // 예산 유형 선택 저장 api 호출
  // Future<bool> saveBudgetTypeSelection(String selectedType) async {
  //   try {
  //     final response = await _apiClient.post(
  //       '/mm/budget/type/selection',
  //       data: {'selectedType': selectedType},
  //     );

  //     return response.statusCode == 200;
  //   } catch (e) {
  //     // 실제 API가 준비되지 않았으므로 항상 성공 반환
  //     print('Using dummy response for budget type selection: $e');
  //     return true;
  //   }
  // }
}