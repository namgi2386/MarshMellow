// lib/data/datasources/remote/finance_api.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marshmellow/data/datasources/remote/api_client.dart';
import 'package:marshmellow/di/providers/api_providers.dart';


class FinanceApi {
  final ApiClient _apiClient;
  
  FinanceApi(this._apiClient);
  
  // 자산 정보 가져오기
  Future<dynamic> getAssetInfo(String userKey) async {
    // 여기서 body를 포함한 GET 요청을 사용
    return await _apiClient.getWithBody(
      '/asset', 
      data: {'userKey': userKey},
    );
  }
}

// FinanceApi 프로바이더 정의
final financeApiProvider = Provider<FinanceApi>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return FinanceApi(apiClient);
});