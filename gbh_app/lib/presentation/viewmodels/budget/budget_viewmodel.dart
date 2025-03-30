import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marshmellow/data/models/budget/budget_model.dart';

class BudgetState {
  final bool isLoading;
  final List<Budget> budgets;
  final int? selectedBudgetIndex;
  final String? errorMessage;

  BudgetState({
    required this.isLoading,
    required this.budgets,
    this.selectedBudgetIndex,
    this.errorMessage,
  });

  factory BudgetState.initial() {
    return BudgetState(
      isLoading: true, 
      budgets: [],
    );
  }

  BudgetState copyWith({
    bool? isLoading,
    List<Budget>? budgets,
    int? selectedBudgetIndex,
    String? errorMessage,
  }) {
    return BudgetState(
      isLoading: isLoading ?? this.isLoading, 
      budgets: budgets ?? this.budgets,
      selectedBudgetIndex: selectedBudgetIndex ?? this.selectedBudgetIndex,
      errorMessage: errorMessage,
    );
  }
  
  // 현재 선택된 예산
  Budget? get selectedBudget {
    if (selectedBudgetIndex == null || budgets.isEmpty || selectedBudgetIndex! >= budgets.length) {
      return null;
    }
    return budgets[selectedBudgetIndex!];
  }

  // 날짜 범위 문자열
  String get dateRangeText {
    if (selectedBudget == null) {
      return '';
    }

    // YYMMDD 형식 날짜를 MM.DD 형식으로 변환
    String startDateStr = selectedBudget!.startDate;
    String endDateStr = selectedBudget!.endDate;

    String startMonth = startDateStr.substring(2,4);
    String startDay = startDateStr.substring(4, 6);
    String endMonth = endDateStr.substring(2,4);
    String endDay = endDateStr.substring(4, 6);

    return '$startMonth.$startDay - $endMonth.$endDay';
  }

  // 남은 예산 계산
  int get remainingBudget {
    if (selectedBudget == null) {
      return 0;
    }

    int totalSpent = 0;
    for (var category in selectedBudget!.budgetCategoryList) {
      totalSpent += category.budgetExpendAmount ?? 0;
    }

    return selectedBudget!.budgetAmount - totalSpent;
  }
}

class BudgetViewmodel extends StateNotifier<BudgetState> {
  // TODO: repository 주입 필요
  BudgetViewmodel() : super(BudgetState.initial()) {
    fetchBudgets();
  }

  Future<void> fetchBudgets() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // TODO: api 호출하시오오
      // final response = await budgetRepository.getBudgetList();

      // mockdata
      final mockResponse = BudgetResponse.fromJson({
        "code": 200,
        "message": "성공",
        "data": {
          "message": "예산 리스트 조회",
          "budgetList": [
            {
              "budgetPk": 36,
              "budgetAmount": 1000000,
              "startDate": "250225",
              "endDate": "250325",
              "budgetCategoryList": [
                {
                  "budgetCategoryPk": 20,
                  "budgetCategoryName": "식비",
                  "budgetCategoryPrice": 250000,
                  "budgetExpendAmount": 189800,
                  "budgetExpendPercent": 0.76
                },
                {
                  "budgetCategoryPk": 21,
                  "budgetCategoryName": "교통비",
                  "budgetCategoryPrice": 100000,
                  "budgetExpendAmount": 26510,
                  "budgetExpendPercent": 0.27
                },
                {
                  "budgetCategoryPk": 22,
                  "budgetCategoryName": "여가",
                  "budgetCategoryPrice": 150000,
                  "budgetExpendAmount": 76000,
                  "budgetExpendPercent": 0.51
                },
                {
                  "budgetCategoryPk": 23,
                  "budgetCategoryName": "커피/디저트",
                  "budgetCategoryPrice": 120000,
                  "budgetExpendAmount": 100000,
                  "budgetExpendPercent": 0.83
                },
                {
                  "budgetCategoryPk": 24,
                  "budgetCategoryName": "쇼핑",
                  "budgetCategoryPrice": 180000,
                  "budgetExpendAmount": 536000,
                  "budgetExpendPercent": 2.98
                },
                {
                  "budgetCategoryPk": 25,
                  "budgetCategoryName": "생활",
                  "budgetCategoryPrice": 80000,
                  "budgetExpendAmount": 45000,
                  "budgetExpendPercent": 0.56
                },
                {
                  "budgetCategoryPk": 26,
                  "budgetCategoryName": "주거",
                  "budgetCategoryPrice": 50000,
                  "budgetExpendAmount": 35000,
                  "budgetExpendPercent": 0.70
                },
                {
                  "budgetCategoryPk": 27,
                  "budgetCategoryName": "의료",
                  "budgetCategoryPrice": 30000,
                  "budgetExpendAmount": 12000,
                  "budgetExpendPercent": 0.40
                },
                {
                  "budgetCategoryPk": 28,
                  "budgetCategoryName": "기타",
                  "budgetCategoryPrice": 40000,
                  "budgetExpendAmount": 100490,
                  "budgetExpendPercent": 2.51
                }
              ]
            },
            {
              "budgetPk": 35,
              "budgetAmount": 1000000,
              "startDate": "250125",
              "endDate": "250225",
              "budgetCategoryList": [
                {
                  "budgetCategoryPk": 9,
                  "budgetCategoryName": "식비",
                  "budgetCategoryPrice": 200000,
                  "budgetExpendAmount": 50000,
                  "budgetExpendPercent": 0.25
                },
                {
                  "budgetCategoryPk": 10,
                  "budgetCategoryName": "교통비",
                  "budgetCategoryPrice": 200000,
                  "budgetExpendAmount": 300000,
                  "budgetExpendPercent": 1.5
                },
                {
                  "budgetCategoryPk": 11,
                  "budgetCategoryName": "여가",
                  "budgetCategoryPrice": 200000,
                  "budgetExpendAmount": 14124,
                  "budgetExpendPercent": 0.07
                },
                {
                  "budgetCategoryPk": 12,
                  "budgetCategoryName": "커피/디저트",
                  "budgetCategoryPrice": 200000,
                  "budgetExpendAmount": 100000,
                  "budgetExpendPercent": 0.5
                }
              ]
            }
          ]
        }
      });

      if (mockResponse.code == 200) {
        state = state.copyWith(
          isLoading: false,
          budgets: mockResponse.data.budgetList,
          selectedBudgetIndex: mockResponse.data.budgetList.isNotEmpty ? 0 : null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: mockResponse.message
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '예산 정보를 불러오는 중 오류 발생: $e',
      );
    }
  }
  
  // 이전/ 다음 예산으로 이동
  void navigateToPreviousBudget() {
    if (state.selectedBudgetIndex == null || state.selectedBudgetIndex! <= 0) {
      return;
    }
    state = state.copyWith(selectedBudgetIndex: state.selectedBudgetIndex! + 1);
  }

  void navigateToNextBudget() {
    if (state.selectedBudgetIndex == null || state.selectedBudgetIndex! >= state.budgets.length -1) {
      return;
    }
    state = state.copyWith(selectedBudgetIndex: state.selectedBudgetIndex! - 1);
  }
}

// 프로바이더 정의
final budgetProvider = StateNotifierProvider<BudgetViewmodel, BudgetState>((ref) {
  return BudgetViewmodel();
});