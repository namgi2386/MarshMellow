// lib/presentation/viewmodels/ledger/ledger_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marshmellow/data/repositories/ledger_repository.dart';
import 'package:marshmellow/data/models/ledger/category/transactions.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';
import 'package:marshmellow/presentation/viewmodels/ledger/transaction_list_viewmodel.dart';

// 가계부 상태 정의
class LedgerState {
  final bool isLoading;
  final List<Transaction> transactions;
  final Map<String, List<Transaction>> groupedTransactions; // 날짜별 그룹화된 거래
  final int totalIncome;
  final int totalExpenditure;
  final String? errorMessage;

  LedgerState({
    this.isLoading = false,
    this.transactions = const [],
    this.groupedTransactions = const {},
    this.totalIncome = 0,
    this.totalExpenditure = 0,
    this.errorMessage,
  });

  LedgerState copyWith({
    bool? isLoading,
    List<Transaction>? transactions,
    Map<String, List<Transaction>>? groupedTransactions,
    int? totalIncome,
    int? totalExpenditure,
    String? errorMessage,
  }) {
    return LedgerState(
      isLoading: isLoading ?? this.isLoading,
      transactions: transactions ?? this.transactions,
      groupedTransactions: groupedTransactions ?? this.groupedTransactions,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpenditure: totalExpenditure ?? this.totalExpenditure,
      errorMessage: errorMessage,
    );
  }
}

// 사용자 정보 (임시, 실제로는 유저 인증 정보에서 가져와야 함)
class UserInfo {
  static const int userPk = 3; // 예시 유저 ID
}

// 가계부 뷰모델
class LedgerViewModel extends StateNotifier<LedgerState> {
  final LedgerRepository _repository;

  LedgerViewModel(this._repository) : super(LedgerState());

  // 날짜 형식 변환 헬퍼 메서드
  String _formatDate(DateTime date) {
    return DateFormat('yyyyMMdd').format(date);
  }

  // 가계부 목록 로드
  Future<void> loadHouseholdData(PickerDateRange dateRange) async {
    if (dateRange.startDate == null) return;

    final startDate = dateRange.startDate!;
    final endDate = dateRange.endDate ?? startDate;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // API 호출 파라미터용 날짜 형식
      final formattedStartDate = _formatDate(startDate);
      final formattedEndDate = _formatDate(endDate);

      // 가계부 목록 조회
      final result = await _repository.getHouseholdList(
        userPk: UserInfo.userPk, // 실제 앱에서는 로그인한 사용자 ID를 사용해야 함
        startDate: formattedStartDate,
        endDate: formattedEndDate,
      );

      state = state.copyWith(
        isLoading: false,
        transactions: result['allTransactions'],
        groupedTransactions: result['groupedTransactions'],
        totalIncome: result['totalIncome'],
        totalExpenditure: result['totalExpenditure'],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  // 거래 내역 추가/삭제 등의 메서드 추가...
}

final ledgerViewModelProvider =
    StateNotifierProvider<LedgerViewModel, LedgerState>((ref) {
  final repository = ref.watch(ledgerRepositoryProvider);
  return LedgerViewModel(repository);
});
