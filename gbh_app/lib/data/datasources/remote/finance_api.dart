import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marshmellow/data/datasources/remote/api_client.dart';
import 'package:marshmellow/data/models/finance/transfer_model.dart';
import 'package:marshmellow/data/models/finance/withdrawal_account_model.dart';
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
  
  Future<AssetResponseModel> getAssetInfo() async {
    final response = await _apiClient.get('/asset');
    print('resp나의onse : ${response}');
    return AssetResponseModel.fromJson(response.data);
  }

  // 입출금 내역조회
  Future<DemandDetailResponse> getDemandAccountTransactions({
    required String accountNo,
    required String startDate,
    required String endDate,
    String transactionType = 'A',
    String? orderByType,
  }) async {
    final data = {
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
    return DemandDetailResponse.fromJson(response.data);
  }

  // 예금 조회 
  Future<DepositDetailResponse> getDepositPayment({
    required String accountNo,
  }) async {
    final data = {
      'accountNo': accountNo,
    };

    final response = await _apiClient.getWithBody('/asset/deposit-payment', data: data);
    return DepositDetailResponse.fromJson(response.data);
  }
  
  // 적금 납입 회차 조회 API
  Future<SavingDetailResponse> getSavingAccountPayments({
    required String accountNo,
  }) async {
    final data = {
      'accountNo': accountNo,
    };

    final response = await _apiClient.getWithBody('/asset/savings-payment', data: data);
    return SavingDetailResponse.fromJson(response.data);
  }

  // 대출 조회 
  Future<LoanDetailResponse> getLoanPaymentDetails({
    required String accountNo,
  }) async {
    final data = {
      'accountNo': accountNo,
    };

    try {
      final response = await _apiClient.getWithBody('/asset/loan-payment', data: data);
      // print("API 응답: $response.data"); // 디버깅용 로그 추가
      return LoanDetailResponse.fromJson(response.data);
    } catch (e) {
      print("API 에러: $e"); // 에러 로그 추가
      rethrow;
    }
  }

  // 카드 거래내역 조회 API 메서드
  Future<CardDetailResponse> getCardTransactions({
    required String cardNo,
    required String cvc,
    required String startDate,
    required String endDate,
  }) async {
    final data = {
      'cardNo': cardNo,
      'cvc': cvc,
      'startDate': startDate,
      'endDate': endDate,
    };

    final response = await _apiClient.getWithBody('/asset/card-transaction', data: data);
    return CardDetailResponse.fromJson(response.data);
  }

  // 출금계좌 목록 조회
  Future<WithdrawalAccountResponse> getWithdrawalAccounts() async {
    final response = await _apiClient.getWithBody('/asset/withdrawal-account');
    // print('Withdrawal accounts response*****************: $response');
    return WithdrawalAccountResponse.fromJson(response.data);
  }

  // 계좌 인증 발송 (1원 송금)
  Future<AccountAuthResponse> sendAccountAuth({
    required String accountNo,
  }) async {
    final data = {
      'accountNo': accountNo,
    };
    
    final response = await _apiClient.post('/asset/open-account-auth', data: data);
    return AccountAuthResponse.fromJson(response.data);
  }

  // 계좌 인증 검증
  Future<AccountAuthVerifyResponse> verifyAccountAuth({
    required String accountNo,
    required String authCode,
  }) async {
    // 디버깅: 타입 확인 및 로그 출력
    // print('authCode 타입: ${authCode.runtimeType}');
    // print('authCode 값: $authCode');
    
    final data = {
      'accountNo': accountNo,
      'authCode': authCode.toString(), // 명시적으로 문자열 변환
    };
    
    // 요청 데이터 확인용 로그
    // print('API 요청 데이터: $data');
    
    final response = await _apiClient.post('/asset/check-account-auth', data: data);
    
    // 응답 확인용 로그
    // print('API 응답: $response');
    
    return AccountAuthVerifyResponse.fromJson(response.data);
  }
  // 계좌 송금
  Future<TransferResponse> transferMoney(TransferRequest request) async {
    final response = await _apiClient.post('/asset/account-transfer', data: request.toJson());
    return TransferResponse.fromJson(response.data);
  }

}

// FinanceApi 프로바이더 정의
final financeApiProvider = Provider<FinanceApi>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return FinanceApi(apiClient);
});