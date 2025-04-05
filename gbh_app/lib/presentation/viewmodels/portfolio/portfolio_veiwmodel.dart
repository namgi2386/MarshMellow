// lib/presentation/viewmodels/portfolio/portfolio_viewmodel.dart
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marshmellow/data/models/cookie/portfolio/portfolio_model.dart';
import 'package:marshmellow/data/models/cookie/portfolio/portfolio_category_model.dart';
import 'package:marshmellow/data/repositories/cookie/portfolio_repositary.dart';
import 'package:marshmellow/di/providers/portfolio_providers.dart';

// 포트폴리오 상태 클래스
class PortfolioState {
  final bool isLoading;
  final List<Portfolio> portfolios;
  final List<PortfolioCategory> categories;
  final String? errorMessage;

  PortfolioState({
    this.isLoading = false,
    this.portfolios = const [],
    this.categories = const [],
    this.errorMessage,
  });

  PortfolioState copyWith({
    bool? isLoading,
    List<Portfolio>? portfolios,
    List<PortfolioCategory>? categories,
    String? errorMessage,
  }) {
    return PortfolioState(
      isLoading: isLoading ?? this.isLoading,
      portfolios: portfolios ?? this.portfolios,
      categories: categories ?? this.categories,
      errorMessage: errorMessage,
    );
  }
}

// 포트폴리오 뷰모델
class PortfolioViewModel extends StateNotifier<PortfolioState> {
  final PortfolioRepository _repository;

  PortfolioViewModel(this._repository) : super(PortfolioState());

  // 포트폴리오 목록 로드
  Future<void> loadPortfolios() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final portfolios = await _repository.getPortfolioList();
      state = state.copyWith(
        isLoading: false,
        portfolios: portfolios,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '포트폴리오 목록을 불러오는데 실패했습니다: $e',
      );
    }
  }

  // 카테고리 목록 로드
  Future<void> loadCategories() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final categories = await _repository.getPortfolioCategories();
      state = state.copyWith(
        isLoading: false,
        categories: categories,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '카테고리 목록을 불러오는데 실패했습니다: $e',
      );
    }
  }

  // 포트폴리오 등록
  Future<Portfolio?> createPortfolio({
    required File file,
    required String portfolioMemo,
    required String fileName,
    required int portfolioCategoryPk,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final portfolio = await _repository.createPortfolio(
        file: file,
        portfolioMemo: portfolioMemo,
        fileName: fileName,
        portfolioCategoryPk: portfolioCategoryPk,
      );

      // 성공적으로 등록되면 포트폴리오 목록에 추가
      final updatedPortfolios = List<Portfolio>.from(state.portfolios)
        ..add(portfolio);

      state = state.copyWith(
        isLoading: false,
        portfolios: updatedPortfolios,
      );

      return portfolio;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '포트폴리오 등록에 실패했습니다: $e',
      );
      return null;
    }
  }

  // 포트폴리오 카테고리 등록
  Future<List<PortfolioCategory>?> createPortfolioCategory({
    required String categoryMemo,
    required String categoryName,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final categories = await _repository.createPortfolioCategory(
        categoryMemo: categoryMemo,
        categoryName: categoryName,
      );

      state = state.copyWith(
        isLoading: false,
        categories: categories,
      );

      return categories;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '카테고리 등록에 실패했습니다: $e',
      );
      return null;
    }
  }

// 포트폴리오 상세 조회 관련 상태와 메서드
  Future<Portfolio?> getPortfolioDetail(int portfolioPk) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final portfolio = await _repository.getPortfolioDetail(
        portfolioPk: portfolioPk,
      );

      state = state.copyWith(isLoading: false);
      return portfolio;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '포트폴리오 상세 정보를 불러오는데 실패했습니다: $e',
      );
      return null;
    }
  }

// 포트폴리오 수정
  Future<Portfolio?> updatePortfolio({
    required int portfolioPk,
    required int portfolioCategoryPk,
    File? file,
    String? portfolioMemo,
    String? fileName,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final updatedPortfolio = await _repository.updatePortfolio(
        portfolioPk: portfolioPk,
        portfolioCategoryPk: portfolioCategoryPk,
        file: file,
        portfolioMemo: portfolioMemo,
        fileName: fileName,
      );

      // 포트폴리오 목록 업데이트
      final updatedPortfolios = state.portfolios.map((portfolio) {
        if (portfolio.portfolioPk == portfolioPk) {
          return updatedPortfolio;
        }
        return portfolio;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        portfolios: updatedPortfolios,
      );

      return updatedPortfolio;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '포트폴리오 수정에 실패했습니다: $e',
      );
      return null;
    }
  }

// 포트폴리오 삭제
  Future<bool> deletePortfolio(int portfolioPk) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final success = await _repository.deletePortfolio(
        portfolioPk: portfolioPk,
      );

      if (success) {
        // 포트폴리오 목록에서 삭제된 항목 제거
        final updatedPortfolios = state.portfolios
            .where((portfolio) => portfolio.portfolioPk != portfolioPk)
            .toList();

        state = state.copyWith(
          isLoading: false,
          portfolios: updatedPortfolios,
        );
      }

      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '포트폴리오 삭제에 실패했습니다: $e',
      );
      return false;
    }
  }

// 카테고리 수정
  Future<PortfolioCategory?> updatePortfolioCategory({
    required int categoryPk,
    String? categoryName,
    String? categoryMemo,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final updatedCategory = await _repository.updatePortfolioCategory(
        categoryPk: categoryPk,
        categoryName: categoryName,
        categoryMemo: categoryMemo,
      );

      // 카테고리 목록 업데이트
      final updatedCategories = state.categories.map((category) {
        if (category.portfolioCategoryPk == categoryPk) {
          return updatedCategory;
        }
        return category;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        categories: updatedCategories,
      );

      return updatedCategory;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '카테고리 수정에 실패했습니다: $e',
      );
      return null;
    }
  }

// 카테고리 삭제
  Future<bool> deletePortfolioCategory(int categoryPk) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final success = await _repository.deletePortfolioCategory(
        categoryPk: categoryPk,
      );

      if (success) {
        // 카테고리 목록에서 삭제된 항목 제거
        final updatedCategories = state.categories
            .where((category) => category.portfolioCategoryPk != categoryPk)
            .toList();

        state = state.copyWith(
          isLoading: false,
          categories: updatedCategories,
        );
      }

      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '카테고리 삭제에 실패했습니다: $e',
      );
      return false;
    }
  }
}

// 포트폴리오 뷰모델 프로바이더
final portfolioViewModelProvider =
    StateNotifierProvider<PortfolioViewModel, PortfolioState>((ref) {
  final repository = ref.watch(portfolioRepositoryProvider);
  return PortfolioViewModel(repository);
});

// 카테고리 목록 비동기 로드 프로바이더
final portfolioCategoryProvider =
    FutureProvider<List<PortfolioCategory>>((ref) async {
  final viewModel = ref.watch(portfolioViewModelProvider.notifier);
  await viewModel.loadCategories();
  return ref.watch(portfolioViewModelProvider).categories;
});

// 포트폴리오 목록 비동기 로드 프로바이더
final portfolioListProvider = FutureProvider<List<Portfolio>>((ref) async {
  final viewModel = ref.watch(portfolioViewModelProvider.notifier);
  await viewModel.loadPortfolios();
  return ref.watch(portfolioViewModelProvider).portfolios;

});

