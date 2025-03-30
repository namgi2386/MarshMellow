import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marshmellow/data/models/ledger/category/transactions.dart';
import 'package:marshmellow/data/repositories/ledger_repository.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:marshmellow/di/providers/date_picker_provider.dart';
import 'package:marshmellow/data/datasources/remote/ledger_api.dart';
import 'package:marshmellow/di/providers/api_providers.dart';

// 사용자 정보 (실제로는 인증에서 가져와야 함)
class UserInfo {
  static const int userPk = 3; // 예시 유저 ID
}

// 가계부부 API 프로바이더
final ledgerApiProvider = Provider<LedgerApi>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return LedgerApi(apiClient);
});

// 가계부 저장소 프로바이더
final ledgerRepositoryProvider = Provider<LedgerRepository>((ref) {
  final ledgerApi = ref.watch(ledgerApiProvider);
  return LedgerRepository(ledgerApi);
});

// 거래 저장소 프로바이더 (ledgerRepositoryProvider와 동일하지만 이름을 다르게 사용)
final transactionRepositoryProvider = Provider<LedgerRepository>((ref) {
  return ref.watch(ledgerRepositoryProvider);
});

// 거래 목록 비동기 프로바이더
final transactionsProvider = FutureProvider<List<Transaction>>((ref) async {
  final repository = ref.watch(transactionRepositoryProvider);
  final datePickerState = ref.watch(datePickerProvider);

  // 선택된 날짜 범위가 없으면 현재 월 사용
  if (datePickerState.selectedRange == null ||
      datePickerState.selectedRange!.startDate == null) {
    final now = DateTime.now();
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0);

    // 기본 날짜 범위 설정
    ref
        .read(datePickerProvider.notifier)
        .updateSelectedRange(PickerDateRange(firstDay, lastDay));

    // 해당 기간의 트랜잭션 조회
    final result = await repository.getHouseholdList(
      userPk: UserInfo.userPk,
      startDate: _formatDate(firstDay),
      endDate: _formatDate(lastDay),
    );

    return result['allTransactions'] as List<Transaction>;
  }

  // 선택된 날짜 범위에 따른 트랜잭션 조회
  final startDate = datePickerState.selectedRange!.startDate!;
  final endDate = datePickerState.selectedRange!.endDate ?? startDate;

  final result = await repository.getHouseholdList(
    userPk: UserInfo.userPk,
    startDate: _formatDate(startDate),
    endDate: _formatDate(endDate),
  );

  return result['allTransactions'] as List<Transaction>;
});

// 날짜 포맷 변환 (yyyyMMdd)
String _formatDate(DateTime date) {
  return '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
}

// 선택된 트랜잭션 ID 상태 프로바이더
final selectedTransactionIdProvider = StateProvider<int?>((ref) => null);

// 거래 상세 정보 비동기 프로바이더
final transactionDetailProvider =
    FutureProvider.family<Transaction, int>((ref, householdPk) async {
  final repository = ref.watch(ledgerRepositoryProvider);
  return repository.getHouseholdDetail(householdPk);
});
