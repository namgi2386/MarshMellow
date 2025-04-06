import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marshmellow/data/models/budget/budget_type_model.dart';
import 'package:marshmellow/data/repositories/budget/budget_type_repository.dart';
import 'package:marshmellow/di/providers/budget/budget_type_provider.dart';

/*
  예산 유형 분석 상태
*/
class BudgetTypeState {
  final bool isLoading;
  final String? errorMessage;
  final BudgetTypeAnalysisResponse? analysisResult;
  final String? myBudgetType;
  final String? selectedType;
  final bool isSavingSelection;

  BudgetTypeState({
    this.isLoading = false,
    this.errorMessage,
    this.analysisResult,
    this.myBudgetType,
    this.selectedType,
    this.isSavingSelection = false,
  });

  BudgetTypeState copyWith({
    bool? isLoading,
    String? errorMessage,
    BudgetTypeAnalysisResponse? analysisResult,
    String? myBudgetType,
    String? selectedType,
    bool? isSavingSelection,
  }) {
    return BudgetTypeState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      analysisResult: analysisResult ?? this.analysisResult,
      myBudgetType: myBudgetType ?? this.myBudgetType,
      selectedType: selectedType ?? this.selectedType,
      isSavingSelection: isSavingSelection ?? this.isSavingSelection,
    );
  }
}

/*
  예산 유형별 분석 viewmodel provider
*/
final budgetTypeProvider = StateNotifierProvider<BudgetTypeViewModel, BudgetTypeState>((ref) {
  final repository = ref.watch(budgetTypeRepositoryProvider);
  return BudgetTypeViewModel(repository);
});

// 예산 유형 분석 ViewModel
class BudgetTypeViewModel extends StateNotifier<BudgetTypeState> {
  final BudgetTypeRepository _repository;

  BudgetTypeViewModel(this._repository) : super(BudgetTypeState()) {
    // 초기 로드
    analyzeBudgetType();
  }

  // 예산 유형 분석
  Future<void> analyzeBudgetType() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      // 실제 데이터가 없는 경우 더미 데이터 사용
      final result = await _repository.analyzeWithDummyData();
      
      // 내 유형 찾기 (my_data의 첫 번째 키)
      final myBudgetType = result.myData.keys.first;
      
      state = state.copyWith(
        isLoading: false,
        analysisResult: result,
        myBudgetType: myBudgetType,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '예산 유형 분석에 실패했습니다: $e',
      );
    }
  }

  // 유형 선택
  void selectBudgetType(String type) {
    state = state.copyWith(selectedType: type);
  }

  // 선택한 유형 저장
  Future<bool> saveSelectedType() async {
    if (state.selectedType == null) return false;
    
    try {
      state = state.copyWith(isSavingSelection: true);
      final result = await _repository.saveBudgetTypeSelection(state.selectedType!);
      state = state.copyWith(isSavingSelection: false);
      return result;
    } catch (e) {
      state = state.copyWith(
        isSavingSelection: false,
        errorMessage: '유형 선택 저장에 실패했습니다: $e',
      );
      return false;
    }
  }

  // 내 예산 유형 데이터 가져오기
  BudgetTypeData? getMyTypeData() {
    if (state.analysisResult == null || state.myBudgetType == null) return null;
    return state.analysisResult!.myData[state.myBudgetType];
  }

  // 선택한 유형의 데이터 가져오기
  BudgetTypeData? getSelectedTypeData() {
    if (state.analysisResult == null || state.selectedType == null) return null;
    return state.analysisResult!.allData[state.selectedType];
  }
}