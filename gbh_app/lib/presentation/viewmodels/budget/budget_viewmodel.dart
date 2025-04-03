import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:marshmellow/data/models/budget/budget_model.dart';
import 'package:marshmellow/data/repositories/budget/budget_repository.dart';
import 'package:marshmellow/di/providers/budget_provider.dart';

// Budget ViewModel 상태 클래스
class BudgetState {
  final List<BudgetModel> budgets;
  final BudgetModel? selectedBudget;
  final DailyBudgetModel? dailyBudget;
  final bool isLoading;
  final String? errorMessage;
  final int currentBudgetIndex;

  BudgetState({
    this.budgets = const [],
    this.selectedBudget,
    this.dailyBudget,
    this.isLoading = false,
    this.errorMessage,
    this.currentBudgetIndex = 0,
  });

  // 날짜 표시 텍스트 계산
  String get dateRangeText {
    if (selectedBudget == null) return '';
    
    final startDate = DateTime.parse(selectedBudget!.startDate);
    final endDate = DateTime.parse(selectedBudget!.endDate);
    
    final formatter = DateFormat('yyyy.MM.dd');
    return '${formatter.format(startDate)} - ${formatter.format(endDate)}';
  }

  BudgetState copyWith({
    List<BudgetModel>? budgets,
    BudgetModel? selectedBudget,
    DailyBudgetModel? dailyBudget,
    bool? isLoading,
    String? errorMessage,
    int? currentBudgetIndex,
  }) {
    return BudgetState(
      budgets: budgets ?? this.budgets,
      selectedBudget: selectedBudget ?? this.selectedBudget,
      dailyBudget: dailyBudget ?? this.dailyBudget,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      currentBudgetIndex: currentBudgetIndex ?? this.currentBudgetIndex,
    );
  }
}

// Budget ViewModel 프로바이더
final budgetProvider = StateNotifierProvider<BudgetViewModel, BudgetState>((ref) {
  final repository = ref.watch(budgetRepositoryProvider);
  return BudgetViewModel(repository);
});

// Budget ViewModel
class BudgetViewModel extends StateNotifier<BudgetState> {
  final BudgetRepository _repository;

  BudgetViewModel(this._repository) : super(BudgetState()) {
    // 초기 데이터 로딩
    fetchBudgets();
    fetchDailyBudget();
  }

  // 전체 예산 로드
  Future<void> fetchBudgets() async {
  try {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final budgets = await _repository.getAllBudgets();
    
    // 예산이 있을 경우 첫 번째 예산을 선택
    BudgetModel? selectedBudget;
    
    if (budgets.isNotEmpty) {
      selectedBudget = budgets[0];
      
      state = state.copyWith(
        budgets: budgets,
        selectedBudget: selectedBudget,
        isLoading: false,
        currentBudgetIndex: 0,
      );
      
      await fetchDailyBudget();
    } else {
      // 예산이 없는 경우 오늘의 예산은 로드하지 않음
      state = state.copyWith(
        budgets: budgets,
        selectedBudget: null,
        isLoading: false,
        currentBudgetIndex: 0,
      );
    }
  } catch (e) {
    // 404 오류는 예산이 없는 정상적인 상황
    if (e.toString().contains("404")) {
      state = state.copyWith(
        budgets: [],
        selectedBudget: null,
        isLoading: false,
        currentBudgetIndex: 0,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
}

  // 일일 예산 로드
  Future<void> fetchDailyBudget() async {
    try {
      // 전체 예산이 없으면 오늘의 예산 로드 생략
      // if (state.budgets.isEmpty) return;

      final dailyBudget = await _repository.getDailyBudget();
      state = state.copyWith(dailyBudget: dailyBudget);
    } catch (e) {
      // 오늘의 예산 로드 실패 시 에러 메시지 표시하지 않음
      print('오늘의 예산 로드 실패: $e');
    }
  }

  // 이전 예산으로 이동
  void navigateToPreviousBudget() {
    if (state.budgets.isEmpty || state.currentBudgetIndex <= 0) return;
    
    final newIndex = state.currentBudgetIndex - 1;
    final newSelectedBudget = state.budgets[newIndex];
    
    state = state.copyWith(
      selectedBudget: newSelectedBudget,
      currentBudgetIndex: newIndex,
    );
    
    // 예산이 변경되면 일일 예산도 다시 로드
    fetchDailyBudget();
  }

  // 다음 예산으로 이동
  void navigateToNextBudget() {
    if (state.budgets.isEmpty || state.currentBudgetIndex >= state.budgets.length - 1) return;
    
    final newIndex = state.currentBudgetIndex + 1;
    final newSelectedBudget = state.budgets[newIndex];
    
    state = state.copyWith(
      selectedBudget: newSelectedBudget,
      currentBudgetIndex: newIndex,
    );
    
    // 예산이 변경되면 일일 예산도 다시 로드
    fetchDailyBudget();
  }

  // 예산 카테고리 업데이트
  Future<void> updateBudgetCategory(int budgetCategoryPk, int newAmount) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      await _repository.updateBudgetCategory(budgetCategoryPk, newAmount);
      
      // 업데이트 후 모든 예산 다시 로드
      await fetchBudgets();
      // 일일 예산도 다시 로드
      await fetchDailyBudget();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  // 예산 알람 시간 업데이트
  Future<void> updateBudgetAlarm(String alarmTime) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      await _repository.updateBudgetAlarm(alarmTime);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }
}