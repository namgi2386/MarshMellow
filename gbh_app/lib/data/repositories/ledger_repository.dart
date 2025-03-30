import 'package:marshmellow/data/datasources/remote/ledger_api.dart';
import 'package:marshmellow/data/models/ledger/category/transactions.dart';
import 'package:marshmellow/data/models/ledger/category/transaction_category.dart';
import 'package:marshmellow/data/models/ledger/category/withdrawal_category.dart';
import 'package:marshmellow/data/models/ledger/category/deposit_category.dart';
import 'package:marshmellow/data/models/ledger/category/transfer_category.dart';
import 'package:intl/intl.dart';
import 'package:marshmellow/presentation/viewmodels/ledger/ledger_viewmodel.dart';

class LedgerRepository {
  final LedgerApi _ledgerApi;

  LedgerRepository(this._ledgerApi);

  // 가계부 조회 (API 명세에 맞게 수정)
  Future<Map<String, dynamic>> getHouseholdList({
    required int userPk,
    required String startDate,
    required String endDate,
  }) async {
    return await _ledgerApi.getHouseholdList(
      userPk: userPk,
      startDate: startDate,
      endDate: endDate,
    );
  }

  // 카테고리 관련 메서드
  WithdrawalCategory? getWithdrawalCategoryByName(String name) {
    try {
      return WithdrawalCategory.getByName(name);
    } catch (e) {
      return null;
    }
  }

  DepositCategory? getDepositCategoryByName(String name) {
    try {
      return DepositCategory.getByName(name);
    } catch (e) {
      return null;
    }
  }

  TransferCategory? getTransferCategoryByName(String name) {
    try {
      return TransferCategory.getByName(name);
    } catch (e) {
      return null;
    }
  }

  // 트랜잭션을 날짜별로 그룹화하는 메서드
  Map<DateTime, List<Transaction>> groupTransactionsByDate(
      List<Transaction> transactions) {
    final result = <DateTime, List<Transaction>>{};

    for (var transaction in transactions) {
      final dateTime = transaction.dateTime;
      final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

      if (!result.containsKey(date)) {
        result[date] = [];
      }

      result[date]!.add(transaction);
    }

    return result;
  }

  // 특정 날짜 범위의 트랜잭션 가져오기
  Future<List<Transaction>> getTransactions({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // 날짜를 API에 맞는 형식으로 변환
    final formattedStartDate = DateFormat('yyyyMMdd').format(startDate);
    final formattedEndDate = DateFormat('yyyyMMdd').format(endDate);

    // API 호출 결과 가져오기
    final result = await getHouseholdList(
      userPk: UserInfo.userPk,
      startDate: formattedStartDate,
      endDate: formattedEndDate,
    );

    // 모든 트랜잭션 반환
    return result['allTransactions'] as List<Transaction>;
  }

  // 가계부 상세 조회
  Future<Transaction> getHouseholdDetail(int householdPk) async {
    return await _ledgerApi.getHouseholdDetail(householdPk);
  }

  // 검색 기능
  Future<List<Transaction>> searchTransactions({
    required int userPk,
    required String startDate,
    required String endDate,
    required String keyword,
  }) async {
    try {
      final result = await _ledgerApi.searchHousehold(
        userPk: userPk,
        startDate: startDate,
        endDate: endDate,
        keyword: keyword,
      );

      return result['transactions'] as List<Transaction>;
    } catch (e) {
      throw Exception('거래 검색에 실패했습니다: $e');
    }
  }
}
