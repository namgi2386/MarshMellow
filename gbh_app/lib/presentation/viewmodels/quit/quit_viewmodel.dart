import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marshmellow/data/models/cookie/quit/quit_model.dart';
import 'package:marshmellow/data/repositories/cookie/quit_repositary.dart';
import 'package:marshmellow/di/providers/quit_providers.dart';

class QuitState {
  final bool isLoading;
  final AverageSpendingData? averageSpending;
  final String? errorMessage;

  QuitState({
    this.isLoading = false,
    this.averageSpending,
    this.errorMessage,
  });

  QuitState copyWith({
    bool? isLoading,
    AverageSpendingData? averageSpending,
    String? errorMessage,
  }) {
    return QuitState(
      isLoading: isLoading ?? this.isLoading,
      averageSpending: averageSpending ?? this.averageSpending,
      errorMessage: errorMessage,
    );
  }
}

class QuitViewModel extends StateNotifier<QuitState> {
  final QuitRepository _repository;

  QuitViewModel(this._repository) : super(QuitState());

  Future<void> loadAverageSpending() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final data = await _repository.getAverageSpending();
      state = state.copyWith(isLoading: false, averageSpending: data);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '평균 지출 데이터를 불러오는데 실패했습니다: $e',
      );
    }
  }
}

// Provider 등록
final quitViewModelProvider = StateNotifierProvider<QuitViewModel, QuitState>((ref) {
  final repository = ref.watch(quitRepositoryProvider);
  return QuitViewModel(repository);
});