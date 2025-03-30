import 'package:marshmellow/data/datasources/remote/api_client.dart';
import 'package:marshmellow/data/models/ledger/category/transactions.dart';

class LedgerApi {
  final ApiClient _apiClient;

  LedgerApi(this._apiClient);

  /// 가계부 목록 조회 (기간별)
  ///
  /// [userPk] 회원 고유번호
  /// [startDate] 조회 시작일 (yyyyMMdd 형식)
  /// [endDate] 조회 종료일 (yyyyMMdd 형식)
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
}
