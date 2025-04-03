import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:marshmellow/data/models/ledger/category/transactions.dart';
import 'package:marshmellow/data/repositories/ledger_repository.dart';
import 'package:marshmellow/data/models/ledger/category/withdrawal_category.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/presentation/pages/ledger/widgets/chart/doughnut_chart_with_legend.dart' as doughnut;
import 'package:marshmellow/presentation/pages/ledger/widgets/chart/column_chart.dart' as column;
import 'package:marshmellow/di/providers/date_picker_provider.dart';
import 'package:marshmellow/presentation/viewmodels/ledger/transaction_list_viewmodel.dart';

// 분석 페이지 상태 정의
class AnalysisState {
  final bool isLoading;
  final List<doughnut.ChartData> categoryChartData;
  final List<column.ChartData> weeklyChartData;
  final double totalExpenses;
  final String? errorMessage;
  final DateTime startDate;
  final DateTime endDate;

  AnalysisState({
    this.isLoading = false,
    this.categoryChartData = const [],
    this.weeklyChartData = const [],
    this.totalExpenses = 0,
    this.errorMessage,
    required this.startDate,
    required this.endDate,
  });

  AnalysisState copyWith({
    bool? isLoading,
    List<doughnut.ChartData>? categoryChartData,
    List<column.ChartData>? weeklyChartData,
    double? totalExpenses,
    String? errorMessage,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return AnalysisState(
      isLoading: isLoading ?? this.isLoading,
      categoryChartData: categoryChartData ?? this.categoryChartData,
      weeklyChartData: weeklyChartData ?? this.weeklyChartData,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      errorMessage: errorMessage,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

// 분석 뷰모델
class AnalysisViewModel extends StateNotifier<AnalysisState> {
  final LedgerRepository _repository;
  
  // 카테고리별 색상 리스트 - 상위 5개 항목에 사용
  final List<Color> _topCategoryColors = [
    AppColors.yellowPrimary,
    AppColors.pinkPrimary,
    AppColors.bluePrimary,
    AppColors.greenPrimary,
    AppColors.whiteLight,
  ];
  
  // 기타 항목의 색상
  final Color _otherCategoryColor = AppColors.blackPrimary;

  AnalysisViewModel(this._repository) 
      : super(AnalysisState(
          startDate: DateTime.now().subtract(const Duration(days: 30)),
          endDate: DateTime.now(),
        ));

  // 날짜 형식 변환 헬퍼 메서드
  String _formatDate(DateTime date) {
    return DateFormat('yyyyMMdd').format(date);
  }

  // 지출 분석 데이터 로드
  Future<void> loadAnalysisData({
    required DateTime startDate, 
    required DateTime endDate,  
  }) async {
    state = state.copyWith(
      isLoading: true, 
      errorMessage: null,
      startDate: startDate,
      endDate: endDate,
    );

    try {
      // API 호출 파라미터 준비
      final formattedStartDate = _formatDate(startDate);
      final formattedEndDate = _formatDate(endDate);

      // 지출 내역만 조회 (WITHDRAWAL)
      final result = await _repository.getHouseholdByClassification(
        startDate: formattedStartDate,
        endDate: formattedEndDate,
        classification: 'WITHDRAWAL', // 지출 내역만 가져오기
      );

      // 트랜잭션 목록
      final transactions = result['transactions'] as List<Transaction>;
      
      // 카테고리별 데이터 처리
      final categoryData = _processCategoryData(transactions);
      
      // 주차별 데이터 처리
      final weeklyData = _processWeeklyData(transactions);
      
      // 총 지출 금액
      final totalExpenses = transactions.fold<double>(
        0, (sum, item) => sum + item.householdAmount);

      state = state.copyWith(
        isLoading: false,
        categoryChartData: categoryData,
        weeklyChartData: weeklyData,
        totalExpenses: totalExpenses,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  // 카테고리별 데이터 처리
  List<doughnut.ChartData> _processCategoryData(List<Transaction> transactions) {
    // 카테고리별 합계 계산
    final Map<String, double> categorySum = {};
    
    for (var transaction in transactions) {
      final category = transaction.householdCategory;
      categorySum[category] = (categorySum[category] ?? 0) + transaction.householdAmount;
    }
    
    // 총액 계산
    final totalAmount = categorySum.values.fold<double>(0, (sum, amount) => sum + amount);
    
    if (totalAmount <= 0) return [];
    
    // 퍼센트로 변환 및 내림차순 정렬
    List<MapEntry<String, double>> categoryPercents = categorySum.entries
        .map((entry) => MapEntry(entry.key, (entry.value / totalAmount) * 100))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // 차트 데이터 생성
    List<doughnut.ChartData> chartData = [];
    
    // 상위 5개 항목은 지정된 색상으로 차트 데이터 추가
    for (int i = 0; i < categoryPercents.length; i++) {
      if (i < 5) {
        chartData.add(doughnut.ChartData(
          title: categoryPercents[i].key,
          value: categoryPercents[i].value,
          color: _topCategoryColors[i],
        ));
      } else {
        // 상위 5개 이외의 항목은 '기타'로 묶음
        double otherPercent = categoryPercents.skip(5).fold(
          0.0, (sum, entry) => sum + entry.value);
        
        if (otherPercent > 0) {
          chartData.add(doughnut.ChartData(
            title: '기타',
            value: otherPercent,
            color: _otherCategoryColor,
          ));
        }
        break;
      }
    }
    
    return chartData;
  }

  // 주차별 데이터 처리
  List<column.ChartData> _processWeeklyData(List<Transaction> transactions) {
    // 결과를 담을 리스트
    List<column.ChartData> weeklyData = [];
    
    // 월급일 설정 (예: 매월 1일)
    int payday = 1;
    
    // 시작 날짜 및 종료 날짜 가져오기
    final startDate = state.startDate;
    final endDate = state.endDate;
    
    // 시작일이 월급일 이전이면 전 달 월급일부터, 아니면 현재 달 월급일부터
    DateTime periodStart;
    if (startDate.day < payday) {
      periodStart = DateTime(startDate.year, startDate.month - 1, payday);
    } else {
      periodStart = DateTime(startDate.year, startDate.month, payday);
    }
    
    // 주차 계산을 위한 리스트
    List<DateTime> weekStarts = [];
    DateTime currentDay = periodStart;
    
    // 주차 시작일 계산 (일주일 단위로)
    while (currentDay.isBefore(endDate)) {
      weekStarts.add(currentDay);
      currentDay = currentDay.add(const Duration(days: 7));
    }
    
    // 마지막 주가 한 주가 안 되더라도 추가
    if (weekStarts.isEmpty || weekStarts.last.isBefore(endDate.subtract(const Duration(days: 1)))) {
      weekStarts.add(currentDay);
    }
    
    // 각 주차별 지출 합계 계산
    for (int i = 0; i < weekStarts.length; i++) {
      DateTime weekStart = weekStarts[i];
      DateTime weekEnd = i < weekStarts.length - 1 
        ? weekStarts[i + 1].subtract(const Duration(days: 1)) 
        : endDate;
      
      // 해당 주차의 지출 합계 계산
      double weekTotal = 0;
      for (var transaction in transactions) {
        DateTime txDate = transaction.dateTime;
        if (txDate.isAfter(weekStart.subtract(const Duration(days: 1))) && 
            txDate.isBefore(weekEnd.add(const Duration(days: 1)))) {
          weekTotal += transaction.householdAmount;
        }
      }
      
      // 주차 라벨 생성 (예: "3월 1주")
      String weekLabel = '${weekStart.month}월 ${i+1}주';
      
      // 차트 데이터 추가
      weeklyData.add(column.ChartData(
        label: weekLabel,
        value: weekTotal,
        color: AppColors.pinkPrimary,
      ));
    }
    
    return weeklyData;
  }

  // 이전 기간으로 이동
  void moveToPreviousPeriod() {
    final currentStartDate = state.startDate;
    final currentEndDate = state.endDate;
    
    // 기간의 길이 계산 (일수)
    final periodLength = currentEndDate.difference(currentStartDate).inDays;
    
    // 이전 기간 계산
    final newEndDate = currentStartDate.subtract(const Duration(days: 1));
    final newStartDate = newEndDate.subtract(Duration(days: periodLength));
    
    // 새 기간으로 데이터 로드
    loadAnalysisData(startDate: newStartDate, endDate: newEndDate);
  }

  // 다음 기간으로 이동
  void moveToNextPeriod() {
    final currentStartDate = state.startDate;
    final currentEndDate = state.endDate;
    
    // 기간의 길이 계산 (일수)
    final periodLength = currentEndDate.difference(currentStartDate).inDays;
    
    // 다음 기간 계산
    final newStartDate = currentEndDate.add(const Duration(days: 1));
    final newEndDate = newStartDate.add(Duration(days: periodLength));
    
    // 현재 날짜를 넘어가지 않도록 조정
    final today = DateTime.now();
    final adjustedEndDate = newEndDate.isAfter(today) ? today : newEndDate;
    
    // 새 기간으로 데이터 로드
    loadAnalysisData(startDate: newStartDate, endDate: adjustedEndDate);
  }
}

// 뷰모델 프로바이더 등록
final analysisViewModelProvider = StateNotifierProvider<AnalysisViewModel, AnalysisState>((ref) {
  final repository = ref.watch(ledgerRepositoryProvider);
  return AnalysisViewModel(repository);
});