import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marshmellow/data/models/cookie/portfolio/portfolio_category_model.dart';
import 'package:marshmellow/data/repositories/cookie/portfolio_repositary.dart';
import 'package:marshmellow/di/providers/portfolio_providers.dart';

// 포트폴리오 카테고리 상태 정의
class PortfolioCategoryState {
  final bool isLoading;
  final List<PortfolioCategoryModel> categories;
  final String? errorMessage;
  final int? selectedCategoryPk;

  PortfolioCategoryState({
    this.isLoading = false,
    this.categories = const [],
    this.errorMessage,
    this.selectedCategoryPk,
  });

  PortfolioCategoryState copyWith({
    bool? isLoading,
    List<PortfolioCategoryModel>? categories,
    String? errorMessage,
    int? selectedCategoryPk,
  }) {
    return PortfolioCategoryState(
      isLoading: isLoading ?? this.isLoading,
      categories: categories ?? this.categories,
      errorMessage: errorMessage,
      selectedCategoryPk: selectedCategoryPk ?? this.selectedCategoryPk,
    );
  }
}

// 포트폴리오 카테고리 ViewModel
class PortfolioCategoryViewModel extends StateNotifier<PortfolioCategoryState> {
  final PortfolioRepository _repository;

  PortfolioCategoryViewModel(this._repository)
      : super(PortfolioCategoryState());

  // 카테고리 목록 로드
  Future<void> loadCategories() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final categories = await _repository.getPortfolioCategoryList();

      state = state.copyWith(
        isLoading: false,
        categories: categories,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  // 카테고리 선택
  void selectCategory(int categoryPk) {
    state = state.copyWith(selectedCategoryPk: categoryPk);
  }

  // 선택된 카테고리 가져오기
  PortfolioCategoryModel? getSelectedCategory() {
    if (state.selectedCategoryPk == null) return null;

    try {
      return state.categories.firstWhere((category) =>
          category.portfolioCategoryPk == state.selectedCategoryPk);
    } catch (e) {
      return null;
    }
  }

  // 포트폴리오 카테고리 등록
  Future<bool> createPortfolioCategory({
    required String categoryName,
    required String categoryMemo,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final updatedCategories = await _repository.createPortfolioCategory(
        categoryName: categoryName,
        categoryMemo: categoryMemo,
      );

      state = state.copyWith(
        isLoading: false,
        categories: updatedCategories,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  // 포트폴리오 카테고리 삭제 
Future<bool> deletePortfolioCategories({
  required List<int> portfolioCategoryPkList,
}) async {
  state = state.copyWith(isLoading: true, errorMessage: null);

  try {
    final result = await _repository.deletePortfolioCategories(
      portfolioCategoryPkList: portfolioCategoryPkList,
    );

    // 성공 시 해당 카테고리들을 목록에서 제거
    final updatedCategories = state.categories
        .where((category) => !portfolioCategoryPkList.contains(category.portfolioCategoryPk))
        .toList();

    state = state.copyWith(
      isLoading: false,
      categories: updatedCategories,
    );

    return result;
  } catch (e) {
    state = state.copyWith(
      isLoading: false,
      errorMessage: e.toString(),
    );
      return false;
    }
  }
}

// 포트폴리오 카테고리 ViewModel 프로바이더
final portfolioCategoryViewModelProvider =
    StateNotifierProvider<PortfolioCategoryViewModel, PortfolioCategoryState>(
        (ref) {
  final repository = ref.watch(portfolioRepositoryProvider);
  return PortfolioCategoryViewModel(repository);
});

// 포트폴리오 카테고리 비동기 데이터 프로바이더
final categoriesProvider =
    FutureProvider<List<PortfolioCategoryModel>>((ref) async {
  final repository = ref.watch(portfolioRepositoryProvider);
  return repository.getPortfolioCategoryList();
});
