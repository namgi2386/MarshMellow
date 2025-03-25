// presentation/viewmodels/finance/transaction_list_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:marshmellow/data/models/ledger/transactions.dart';
import 'package:marshmellow/data/repositories/transaction_repository.dart';
import 'package:marshmellow/data/repositories/transaction_category_repository.dart';

// 트랜잭션 저장소 프로바이더
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

// 트랜잭션 카테고리 저장소 프로바이더
final transactionCategoryRepositoryProvider = Provider<TransactionCategoryRepository>((ref) {
  return TransactionCategoryRepository();
});

// 선택된 기간 프로바이더
final selectedPeriodProvider = StateProvider<DateTimeRange>((ref) {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, 1);
  final end = DateTime(now.year, now.month + 1, 0);
  
  return DateTimeRange(start: start, end: end);
});

// 기간 내 트랜잭션 목록 프로바이더
final transactionsProvider = FutureProvider<List<Transaction>>((ref) async {
  final repository = ref.watch(transactionRepositoryProvider);
  final period = ref.watch(selectedPeriodProvider);
  
  return repository.getTransactions(
    startDate: period.start,
    endDate: period.end,
  );
});

// 날짜별 그룹화된 트랜잭션 프로바이더
final groupedTransactionsProvider = Provider<Map<DateTime, List<Transaction>>>((ref) {
  final transactionsAsync = ref.watch(transactionsProvider);
  
  return transactionsAsync.when(
    data: (transactions) {
      final repository = ref.watch(transactionRepositoryProvider);
      return repository.groupTransactionsByDate(transactions);
    },
    loading: () => {},
    error: (_, __) => {},
  );
});

// 기간 내 요약 정보 프로바이더
final periodSummaryProvider = Provider<Map<String, double>>((ref) {
  final transactionsAsync = ref.watch(transactionsProvider);
  
  return transactionsAsync.when(
    data: (transactions) {
      final repository = ref.watch(transactionRepositoryProvider);
      return repository.calculateMonthSummary(transactions);
    },
    loading: () => {'income': 0, 'expense': 0},
    error: (_, __) => {'income': 0, 'expense': 0},
  );
});