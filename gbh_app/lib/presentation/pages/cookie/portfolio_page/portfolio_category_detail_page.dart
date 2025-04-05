import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:marshmellow/core/constants/icon_path.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/presentation/widgets/custom_appbar/custom_appbar.dart';
import 'package:marshmellow/presentation/pages/cookie/widgets/portfolio/portfolio_item.dart';
import 'package:marshmellow/presentation/viewmodels/portfolio/portfolio_viewmodel.dart';
import 'package:marshmellow/presentation/widgets/modal/modal.dart';
import 'package:marshmellow/presentation/pages/cookie/widgets/portfolio/portfolio_form.dart';

class PortfolioCategoryDetailPage extends ConsumerStatefulWidget {
  final int categoryPk;

  const PortfolioCategoryDetailPage({Key? key, required this.categoryPk})
      : super(key: key);

  @override
  ConsumerState<PortfolioCategoryDetailPage> createState() =>
      _PortfolioCategoryDetailPageState();
}

class _PortfolioCategoryDetailPageState
    extends ConsumerState<PortfolioCategoryDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 특정 카테고리의 포트폴리오만 로드
      ref
          .read(portfolioViewModelProvider.notifier)
          .loadPortfoliosByCategory(widget.categoryPk);
    });
  }

  @override
  Widget build(BuildContext context) {
    final portfolioState = ref.watch(portfolioViewModelProvider);
    final categoryPortfolios = portfolioState.portfolios
        .where((p) =>
            p.portfolioCategory?.portfolioCategoryPk == widget.categoryPk)
        .toList();

    // 현재 카테고리 정보 찾기
    final currentCategory = portfolioState.categories.firstWhere(
      (c) => c.portfolioCategoryPk == widget.categoryPk,
      orElse: () => throw Exception('Category not found'),
    );

    return Scaffold(
      appBar: CustomAppbar(
        title: currentCategory.portfolioCategoryName,
        actions: [
          IconButton(
            onPressed: () {
              showCustomModal(
                context: context,
                backgroundColor: AppColors.background,
                child: PortfolioForm(),
              );
            },
            icon: SvgPicture.asset(IconPath.add),
          ),
        ],
      ),
      body: categoryPortfolios.isEmpty
          ? _buildEmptyState()
          : _buildPortfolioList(categoryPortfolios),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/characters/char_melong.png',
            height: 150,
          ),
          const SizedBox(height: 16),
          Text(
            '우측 상단의 + 버튼을 눌러\n포트폴리오를 추가해보세요.',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioList(List portfolios) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: portfolios.length,
              itemBuilder: (context, index) {
                final portfolio = portfolios[index];
                return PortfolioItem(
                  portfolio: portfolio,
                  onTap: () {
                    // 포트폴리오 상세보기 로직 추가 가능
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
