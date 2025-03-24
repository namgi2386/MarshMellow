import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marshmellow/data/datasources/remote/api_client.dart';
import 'package:marshmellow/di/providers/api_providers.dart';
import 'package:marshmellow/data/models/finance/asset_response_model.dart';

// API 정의
class FinanceApi {
  final ApiClient _apiClient;
  
  FinanceApi(this._apiClient); // 의존성 주입
  
  Future<AssetResponseModel> getAssetInfo(String userKey) async {
    final response = await _apiClient.getWithBody('/asset', data: {'userKey': userKey});
    return AssetResponseModel.fromJson(response);
  }
}

// FinanceApi 프로바이더 정의
final financeApiProvider = Provider<FinanceApi>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return FinanceApi(apiClient);
});