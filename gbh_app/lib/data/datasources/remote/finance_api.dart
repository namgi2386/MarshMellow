import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marshmellow/data/datasources/remote/api_client.dart';
import 'package:marshmellow/di/providers/api_providers.dart';
//detail
import 'package:marshmellow/data/models/finance/asset_response_model.dart';
import 'package:marshmellow/data/models/finance/detail/card_detail_model.dart';
import 'package:marshmellow/data/models/finance/detail/demand_detail_model.dart';
import 'package:marshmellow/data/models/finance/detail/deposit_detail_model.dart';
import 'package:marshmellow/data/models/finance/detail/loan_detail_model.dart';
import 'package:marshmellow/data/models/finance/detail/saving_detail_model.dart';

// API 정의
class FinanceApi {
  final ApiClient _apiClient;
  
  FinanceApi(this._apiClient); // 의존성 주입
  
  Future<AssetResponseModel> getAssetInfo(String userKey) async {
    final response = await _apiClient.getWithBody('/asset', data: {'userKey': userKey});
    return AssetResponseModel.fromJson(response);
  }

  // 입출금 내역조회
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

  // 예금 조회 
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

  // 대출 조회 
  Future<LoanDetailResponse> getLoanPaymentDetails({
    required String userKey,
    required String accountNo,
  }) async {
    final data = {
      'userKey': userKey,
      'accountNo': accountNo,
    };

    try {
      final response = await _apiClient.getWithBody('/asset/loan-payment', data: data);
      print("API 응답: $response"); // 디버깅용 로그 추가
      return LoanDetailResponse.fromJson(response);
    } catch (e) {
      print("API 에러: $e"); // 에러 로그 추가
      rethrow;
    }
  }

  // 카드 거래내역 조회 API 메서드
  Future<CardDetailResponse> getCardTransactions({
    required String userKey,
    required String cardNo,
    required String cvc,
    required String startDate,
    required String endDate,
  }) async {
    final data = {
      'userKey': userKey,
      'cardNo': cardNo,
      'cvc': cvc,
      'startDate': startDate,
      'endDate': endDate,
    };

    final response = await _apiClient.getWithBody('/asset/card-transaction', data: data);
    return CardDetailResponse.fromJson(response);
  }

}

// FinanceApi 프로바이더 정의
final financeApiProvider = Provider<FinanceApi>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return FinanceApi(apiClient);
});