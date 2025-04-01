import 'package:marshmellow/data/datasources/remote/api_client.dart';
import 'package:marshmellow/data/models/ledger/category/transactions.dart';

class LedgerApi {
  final ApiClient _apiClient;

  LedgerApi(this._apiClient);

  // 가계부 목록 조회 (기간별)
  //
  // [userPk] 회원 고유번호
  // [startDate] 조회 시작일 (yyyyMMdd 형식)
  // [endDate] 조회 종료일 (yyyyMMdd 형식)
  Future<Map<String, dynamic>> getHouseholdList({
    required int userPk,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await _apiClient.getWithBody(
        '/household/list',
        data: {
          'userPk': userPk,
          'startDate': startDate,
          'endDate': endDate,
        },
      );

      if (response['code'] == 200 && response['data'] != null) {
        final data = response['data'];

        // 총 수입/지출 데이터
        final totalIncome = data['totalIncome'] ?? 0;
        final totalExpenditure = data['totalExpenditure'] ?? 0;

        // 날짜별 가계부 목록 처리
        final householdList = data['householdList'] ?? [];

        // 날짜별로 그룹화된 트랜잭션 목록
        final Map<String, List<Transaction>> groupedTransactions = {};

        // 모든 트랜잭션 목록
        final List<Transaction> allTransactions = [];

        // householdList 순회하며 트랜잭션 변환
        for (var dateGroup in householdList) {
          final date = dateGroup['date'] as String;
          final list = dateGroup['list'] as List;

          groupedTransactions[date] = [];

          for (var item in list) {
            final transaction = Transaction.fromJson(item);
            groupedTransactions[date]!.add(transaction);
            allTransactions.add(transaction);
          }
        }

        // 결과 반환
        return {
          'totalIncome': totalIncome,
          'totalExpenditure': totalExpenditure,
          'groupedTransactions': groupedTransactions,
          'allTransactions': allTransactions,
        };
      }

      throw Exception('API 응답 에러: ${response['message']}');
    } catch (e) {
      throw Exception('가계부 목록을 가져오는데 실패했습니다: $e');
    }
  }

  // 가계부 상세 조회
  Future<Transaction> getHouseholdDetail(int householdPk) async {
    try {
      final response = await _apiClient.getWithBody(
        '/household',
        data: {
          'householdPk': householdPk,
        },
      );

      if (response['code'] == 200 && response['data'] != null) {
        final data = response['data'];
        return Transaction.fromJson(data);
      }

      throw Exception('API 응답 에러: ${response['message']}');
    } catch (e) {
      throw Exception('가계부 상세 정보를 가져오는데 실패했습니다: $e');
    }
  }

  // 검색 기능
  // LedgerApi에서 수정할 부분
  Future<Map<String, dynamic>> searchHousehold({
    required int userPk,
    required String startDate,
    required String endDate,
    required String keyword,
  }) async {
    try {
      final response = await _apiClient.getWithBody(
        '/household/search',
        data: {
          'userPk': userPk,
          'startDate': startDate,
          'endDate': endDate,
          'keyword': keyword,
        },
      );

      if (response['code'] == 200 && response['data'] != null) {
        final data = response['data'];
        final householdList = data['householdList'] ?? [];

        // 검색된 트랜잭션 목록
        final List<Transaction> transactions = [];

        // householdList를 트랜잭션으로 변환
        for (var item in householdList) {
          try {
            // 디버깅을 위해 로그 추가
            print('Processing item: ${item['tradeName']}');

            // API 응답에 필요한 필드가 모두 있는지 확인
            final transaction = Transaction.fromJson(item);
            transactions.add(transaction);
          } catch (e) {
            print('Error parsing transaction: $e');
            // 파싱 오류가 발생해도 계속 진행
          }
        }

        // 결과 반환
        return {
          'transactions': transactions,
        };
      }

      throw Exception('API 응답 에러: ${response['message']}');
    } catch (e) {
      throw Exception('가계부 검색에 실패했습니다: $e');
    }
  }

  // 가계부 삭제
  Future<Map<String, dynamic>> deleteHousehold({
    required int householdPk,
  }) async {
    try {
      final response = await _apiClient.delete(
        '/household',
        data: {
          'householdPk': householdPk,
        },
      );

      if (response['code'] == 200) {
        return response['data'];
      }

      throw Exception('API 응답 에러: ${response['message']}');
    } catch (e) {
      throw Exception('가계부 삭제에 실패했습니다: $e');
    }
  }

  // 가계부 수정
  Future<Transaction> updateHousehold({
    required int householdPk,
    int? householdAmount,
    String? householdMemo,
    String? exceptedBudgetYn,
    int? householdDetailCategoryPk, 
  }) async {
    try {
      // API 요청 데이터 준비
      final Map<String, dynamic> requestData = {
        'householdPk': householdPk,
      };

      // 선택적 매개변수 추가
      if (householdAmount != null)
        requestData['householdAmount'] = householdAmount;
      if (householdMemo != null) requestData['householdMemo'] = householdMemo;
      if (exceptedBudgetYn != null)
        requestData['exceptedBudgetYn'] = exceptedBudgetYn;
      if (householdDetailCategoryPk != null)
        requestData['householdDetailCategoryPk'] = householdDetailCategoryPk;

      final response = await _apiClient.patch(
        '/household',
        data: requestData,
      );

      if (response['code'] == 200 && response['data'] != null) {
        final data = response['data'];
        return Transaction.fromJson(data);
      }

      throw Exception('API 응답 에러: ${response['message']}');
    } catch (e) {
      throw Exception('가계부 수정에 실패했습니다: $e');
    }
  }

  // 가계부 분류별 조회 API 호출
  Future<Map<String, dynamic>> getHouseholdFilter({
    required int userPk,
    required String startDate,
    required String endDate,
    required String classification, // 'DEPOSIT', 'WITHDRAWAL', 'TRANSFER'
  }) async {
    try {
      final response = await _apiClient.getWithBody(
        '/household/filter',
        data: {
          'userPk': userPk,
          'startDate': startDate,
          'endDate': endDate,
          'classification': classification,
        },
      );

      if (response['code'] == 200 && response['data'] != null) {
        return response['data'];
      }

      throw Exception('API 응답 에러: ${response['message']}');
    } catch (e) {
      throw Exception('분류별 가계부 목록을 가져오는데 실패했습니다: $e');
    }
  }
}
