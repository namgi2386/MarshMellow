import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:marshmellow/core/constants/icon_path.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/data/models/cookie/portfolio/portfolio_category_model.dart';
import 'package:marshmellow/data/models/cookie/portfolio/portfolio_model.dart';
import 'package:marshmellow/presentation/pages/cookie/widgets/portfolio/portfolio_category_item.dart';
import 'package:marshmellow/presentation/pages/cookie/widgets/portfolio/portfolio_form.dart';
import 'package:marshmellow/presentation/widgets/custom_appbar/custom_appbar.dart';
import 'package:marshmellow/presentation/widgets/custom_search_bar/custom_search_bar.dart';
import 'package:marshmellow/presentation/widgets/modal/modal.dart';
import 'package:marshmellow/presentation/viewmodels/portfolio/portfolio_viewmodel.dart';
import 'package:marshmellow/presentation/pages/cookie/widgets/portfolio/portfolio_item.dart';
import 'package:marshmellow/router/routes/cookie_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:marshmellow/presentation/widgets/completion_message/completion_message.dart';
import 'package:marshmellow/presentation/pages/cookie/widgets/portfolio/portfolio_delete_confirm.dart';
import 'package:marshmellow/presentation/pages/cookie/widgets/portfolio/portfolio_detail_modal.dart';
import 'package:marshmellow/presentation/widgets/modal/modal.dart';

class PortfolioPage extends ConsumerStatefulWidget {
  const PortfolioPage({super.key});

  @override
  ConsumerState<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends ConsumerState<PortfolioPage>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();

  // 선택 모드 관련 상태 변수
  bool _isSelectionMode = false;
  Set<int> _selectedCategories = {};
  Set<int> _selectedPortfolios = {};

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(portfolioViewModelProvider.notifier).loadData();
    });
  }

  // 포트폴리오 삭제 처리
  Future<void> _deletePortfolio(Portfolio portfolio) async {
    try {
      final success = await ref
          .read(portfolioViewModelProvider.notifier)
          .deletePortfolio(portfolio.portfolioPk ?? 0);

      if (context.mounted) {
        if (success) {
          CompletionMessage.show(context, message: '삭제 완료');
          ref.read(portfolioViewModelProvider.notifier).loadData();
        } else {
          CompletionMessage.show(context,
              message:
                  ref.read(portfolioViewModelProvider).errorMessage ?? '삭제 실패');
        }
      }
    } catch (e) {
      if (context.mounted) {
        CompletionMessage.show(context, message: '오류 발생');
      }
    }
  }

  // 선택한 항목 모두 삭제
  Future<void> _deleteSelected() async {
    if (!mounted) return;

    // 확인 대화상자 표시
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmModal(
        title: '알림',
        subtitle: '정말 삭제하시겠습니까?',
        description: '선택한 항목이 영구적으로 삭제되며 \n 복구할 수 없습니다.',
        cancelText: '취소',
        confirmText: '삭제',
      ),
    );

    if (confirm != true || !mounted) return;

    try {
      bool hasErrors = false;

      // 선택된 카테고리 삭제
      for (final categoryPk in _selectedCategories) {
        if (!mounted) return;
        final success = await ref
            .read(portfolioViewModelProvider.notifier)
            .deletePortfolioCategory(categoryPk);

        if (!success) hasErrors = true;
      }

      // 선택된 포트폴리오 삭제
      for (final portfolioPk in _selectedPortfolios) {
        if (!mounted) return;
        final success = await ref
            .read(portfolioViewModelProvider.notifier)
            .deletePortfolio(portfolioPk);

        if (!success) hasErrors = true;
      }

      if (!mounted) return;

      if (hasErrors) {
        CompletionMessage.show(context, message: '삭제 실패');
      } else {
        CompletionMessage.show(context, message: '삭제 완료');
      }

      // 선택 모드 종료 및 데이터 새로고침
      setState(() {
        _isSelectionMode = false;
        _selectedCategories.clear();
        _selectedPortfolios.clear();
      });

      ref.read(portfolioViewModelProvider.notifier).loadData();
    } catch (e) {
      if (!mounted) return;
      CompletionMessage.show(context, message: '오류가 발생했습니다: $e');
    }
  }

  // 카테고리 아이템 선택/해제 토글
  void _toggleCategorySelection(int categoryPk) {
    setState(() {
      if (_selectedCategories.contains(categoryPk)) {
        _selectedCategories.remove(categoryPk);
      } else {
        _selectedCategories.add(categoryPk);
      }
    });
  }

  // 포트폴리오 아이템 선택/해제 토글
  void _togglePortfolioSelection(int portfolioPk) {
    setState(() {
      if (_selectedPortfolios.contains(portfolioPk)) {
        _selectedPortfolios.remove(portfolioPk);
      } else {
        _selectedPortfolios.add(portfolioPk);
      }
    });
  }

  // 선택 모드 시작
  void _startSelectionMode() {
    setState(() {
      _isSelectionMode = true;
    });
  }

  // 선택 모드 종료
  void _endSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedCategories.clear();
      _selectedPortfolios.clear();
    });
  }

  // 모든 항목 선택
  void _selectAll(
      List<PortfolioCategory> categories, List<Portfolio> portfolios) {
    setState(() {
      _selectedCategories = categories
          .where((c) => c.portfolioCategoryName != '미분류')
          .map((c) => c.portfolioCategoryPk)
          .toSet();

      _selectedPortfolios = portfolios
          .where((p) => p.portfolioCategory?.portfolioCategoryName == '미분류')
          .map((p) => p.portfolioPk ?? 0)
          .toSet();
    });
  }

  // 모든 항목 선택 해제
  void _deselectAll() {
    setState(() {
      _selectedCategories.clear();
      _selectedPortfolios.clear();
    });
  }

  // 포트폴리오 상세 모달을 표시하는 메서드
  void _showPortfolioDetailModal(Portfolio portfolio) {
    showCustomModal(
      context: context,
      ref: ref,
      backgroundColor: AppColors.background,
      child: PortfolioDetailModal(portfolio: portfolio),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final portfolioState = ref.watch(portfolioViewModelProvider);
    final isLoading = portfolioState.isLoading;
    final errorMessage = portfolioState.errorMessage;

    // 미분류가 아닌 카테고리만 필터링
    final filteredCategories = portfolioState.categories
        .where((category) => category.portfolioCategoryName != '미분류')
        .toList();

    // 미분류 카테고리의 포트폴리오만 필터링
    final unclassifiedPortfolios = portfolioState.portfolios
        .where((portfolio) =>
            portfolio.portfolioCategory?.portfolioCategoryName == '미분류')
        .toList();

    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('오류 발생: $errorMessage'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('다시 시도'),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppbar(
        title: '포트폴리오',
        actions: [
          if (!_isSelectionMode)
            IconButton(
              onPressed: () {
                showCustomModal(
                  context: context,
                  ref: ref,
                  backgroundColor: AppColors.background,
                  child: PortfolioForm(),
                );
              },
              icon: SvgPicture.asset(IconPath.add),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              children: [
                // 검색바
                if (!_isSelectionMode)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: CustomSearchBar(
                      controller: _searchController,
                      onChanged: (value) {
                        // TODO: 검색 기능 구현
                      },
                      onSubmitted: (value) {
                        // TODO: 검색 제출 처리
                      },
                    ),
                  ),

                // 선택 모드 컨트롤바
                if (_isSelectionMode)
                  Container(
                    height: 60,
                    color: AppColors.background,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // 닫기 버튼
                        TextButton(
                          onPressed: _endSelectionMode,
                          child: Text(
                            '닫기',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),

                        // 전체 선택 버튼
                        TextButton(
                          onPressed: () => _selectAll(
                              filteredCategories, unclassifiedPortfolios),
                          child: Text(
                            '전체 선택',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),

                        // 전체 해제 버튼
                        TextButton(
                          onPressed: _deselectAll,
                          child: Text(
                            '전체 해제',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),

                        // 삭제 버튼
                        IconButton(
                          onPressed: _selectedCategories.isNotEmpty ||
                                  _selectedPortfolios.isNotEmpty
                              ? _deleteSelected
                              : null,
                          icon: SvgPicture.asset(
                            IconPath.trash,
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // 스크롤 가능한 콘텐츠 영역
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (filteredCategories.isNotEmpty)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 5,
                          childAspectRatio: 300 / 260,
                        ),
                        itemCount: filteredCategories.length,
                        itemBuilder: (context, index) {
                          final category = filteredCategories[index];
                          final isSelected = _selectedCategories
                              .contains(category.portfolioCategoryPk);

                          return CategoryItem(
                            category: category,
                            isSelected: isSelected,
                            isSelectionMode: _isSelectionMode,
                            onTap: _isSelectionMode
                                ? () => _toggleCategorySelection(
                                    category.portfolioCategoryPk)
                                : () {
                                    context
                                        .push(CookieRoutes
                                            .getPortfolioCategoryDetailPath(
                                                category.portfolioCategoryPk))
                                        .then((_) {
                                      ref
                                          .read(portfolioViewModelProvider
                                              .notifier)
                                          .loadData();
                                    });
                                  },
                            onLongPress: () {
                              if (!_isSelectionMode) {
                                _startSelectionMode();
                                _toggleCategorySelection(
                                    category.portfolioCategoryPk);
                              }
                            },
                          );
                        },
                      ),

                    // 포트폴리오 목록 섹션
                    if (unclassifiedPortfolios.isEmpty && !_isSelectionMode)
                      Center(
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/characters/char_melong.png',
                              width: 120,
                              height: 120,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '우측 상단의 + 버튼을 눌러\n포트폴리오를 추가해보세요.',
                              style: AppTextStyles.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else if (unclassifiedPortfolios.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: unclassifiedPortfolios.length,
                        itemBuilder: (context, index) {
                          final portfolio = unclassifiedPortfolios[index];
                          final isSelected = _selectedPortfolios
                              .contains(portfolio.portfolioPk);

                          return PortfolioItem(
                            portfolio: portfolio,
                            isSelected: isSelected,
                            isSelectionMode: _isSelectionMode,
                            onTap: _isSelectionMode
                                ? () => _togglePortfolioSelection(
                                    portfolio.portfolioPk ?? 0)
                                : () => _showPortfolioDetailModal(portfolio),
                            onSelectionToggle: () => _togglePortfolioSelection(
                                portfolio.portfolioPk ?? 0),
                            onLongPress: () {
                              if (!_isSelectionMode) {
                                _startSelectionMode();
                                _togglePortfolioSelection(
                                    portfolio.portfolioPk ?? 0);
                              }
                            },
                            onDelete: (portfolio) =>
                                _deletePortfolio(portfolio),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
