import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:marshmellow/core/constants/icon_path.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/data/models/cookie/portfolio/portfolio_category_model.dart';
import 'package:marshmellow/data/models/cookie/portfolio/portfolio_model.dart';
import 'package:marshmellow/presentation/pages/cookie/widgets/portfolio/category_item.dart';
import 'package:marshmellow/presentation/pages/cookie/widgets/portfolio/portfolio_form.dart';
import 'package:marshmellow/presentation/widgets/custom_appbar/custom_appbar.dart';
import 'package:marshmellow/presentation/widgets/custom_search_bar/custom_search_bar.dart';
import 'package:marshmellow/presentation/widgets/modal/modal.dart';
import 'package:marshmellow/presentation/viewmodels/portfolio/portfolio_viewmodel.dart';
import 'package:marshmellow/presentation/pages/cookie/widgets/portfolio/portfolio_item.dart';
import 'package:marshmellow/router/routes/cookie_routes.dart';
import 'package:go_router/go_router.dart';

class PortfolioPage extends ConsumerStatefulWidget {
  const PortfolioPage({super.key});

  @override
  ConsumerState<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends ConsumerState<PortfolioPage>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final portfolioState = ref.watch(portfolioViewModelProvider);
    final categories = portfolioState.categories;
    final isLoading = portfolioState.isLoading;
    final errorMessage = portfolioState.errorMessage;

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
          IconButton(
            onPressed: () {
              showCustomModal(
                context: context,
                backgroundColor: AppColors.background,
                child: const PortfolioForm(),
              );
            },
            icon: SvgPicture.asset(IconPath.add),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              if (categories.isNotEmpty)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                    childAspectRatio: 300 / 260,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return CategoryItem(
                      category: category,
                      onTap: () {
                        context
                            .push(CookieRoutes.getPortfolioCategoryDetailPath(
                                category.portfolioCategoryPk))
                            .then((_) {
                          // 상세 페이지에서 돌아왔을 때 데이터 새로고침
                          ref
                              .read(portfolioViewModelProvider.notifier)
                              .loadData();
                        });
                      },
                    );
                  },
                ),

              // 포트폴리오 목록 섹션
              if (portfolioState.portfolios.isEmpty)
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
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: portfolioState.portfolios.length,
                  itemBuilder: (context, index) {
                    final portfolio = portfolioState.portfolios[index];
                    return PortfolioItem(
                      portfolio: portfolio,
                      onTap: () {
                        // TODO: 포트폴리오 상세보기 로직 추가
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
