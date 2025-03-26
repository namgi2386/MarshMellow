import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marshmellow/data/datasources/remote/api_client.dart';
import 'package:marshmellow/data/models/finance/detail/deposit_detail_model.dart';
import 'package:marshmellow/data/models/finance/detail/saving_detail_model.dart';
import 'package:marshmellow/di/providers/api_providers.dart';
import 'package:marshmellow/data/models/finance/asset_response_model.dart';
//detail
import 'package:marshmellow/data/models/finance/detail/demand_detail_model.dart';

// API 정의
class FinanceApi {
  final ApiClient _apiClient;
  
  FinanceApi(this._apiClient); // 의존성 주입
  
  Future<AssetResponseModel> getAssetInfo(String userKey) async {
    final response = await _apiClient.getWithBody('/asset', data: {'userKey': userKey});
    return AssetResponseModel.fromJson(response);
  }

  // Demand detail
  Future<DemandDetailResponse> getDemandAccountTransactions({
    required String userKey,
    required String accountNo,
    required String startDate,
    required String endDate,
    String transactionType = 'A',
    String? orderByType,
  }) async {
    final data = {
      'userKey': userKey,
      'accountNo': accountNo,
      'startDate': startDate,
      'endDate': endDate,
      'transactionType': transactionType,
    };
    
    // orderByType이 null이 아닌 경우에만 추가
    if (orderByType != null) {
      data['orderByType'] = orderByType;
    }

    final response = await _apiClient.getWithBody('/asset/deposit-demand-transaction', data: data);
    return DemandDetailResponse.fromJson(response);
  }

  // Deposit detail
  Future<DepositDetailResponse> getDepositPayment({
    required String userKey,
    required String accountNo,
  }) async {
    final data = {
      'userKey': userKey,
      'accountNo': accountNo,
    };

    final response = await _apiClient.getWithBody('/asset/deposit-payment', data: data);
    return DepositDetailResponse.fromJson(response);
  }

  // 적금 납입 회차 조회 API
  Future<SavingDetailResponse> getSavingAccountPayments({
    required String userKey,
    required String accountNo,
  }) async {
    final data = {
      'userKey': userKey,
      'accountNo': accountNo,
    };

    final response = await _apiClient.getWithBody('/asset/savings-payment', data: data);
    return SavingDetailResponse.fromJson(response);
  }
}

// FinanceApi 프로바이더 정의
final financeApiProvider = Provider<FinanceApi>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return FinanceApi(apiClient);
});