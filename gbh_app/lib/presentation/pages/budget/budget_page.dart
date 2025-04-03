import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/presentation/pages/budget/widgets/budget_bubble_chart.dart';
import 'package:marshmellow/presentation/viewmodels/budget/budget_viewmodel.dart';
import 'package:marshmellow/presentation/viewmodels/wishlist/wishlist_viewmodel.dart';
import 'package:marshmellow/presentation/widgets/custom_appbar/custom_appbar.dart';
import 'package:marshmellow/data/models/wishlist/wishlist_model.dart'; 

class BudgetPage extends ConsumerStatefulWidget {
  const BudgetPage({super.key});

  @override
  ConsumerState<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends ConsumerState<BudgetPage> {
  @override
  void initState() {
    super.initState();
    // 화면이 처음 로드될 때 위시리스트 데이터 가져오기
    Future.microtask(() {
      final budgetState = ref.read(budgetProvider);
      if (!budgetState.isLoading && budgetState.budgets.isNotEmpty) {
        ref.read(wishlistProvider.notifier).fetchWishlists();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(budgetProvider);
    // 위시리스트 상태 가져오기
    final wishlistState = ref.watch(wishlistProvider);

    if (state.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        )
      );
    }

    if (state.errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('오류: ${state.errorMessage}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(budgetProvider.notifier).fetchBudgets();
                },
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.budgets.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            '예산',
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.black),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.account_circle_outlined, color: Colors.black),
              onPressed: () {},
            ),
          ],
        ),
        body: const Center(
          child: Text('등록된 예산이 없습니다.'),
        ),
      );
    }

    final selectedBudget = state.selectedBudget;
    if (selectedBudget == null) {
      return const Scaffold(
        body: Center(
          child: Text('선택된 예산이 없습니다')
        ),
      );
    }

    final categories = selectedBudget.budgetCategoryList;
    final remainingBudget = state.dailyBudget?.remainBudgetAmount ?? 0;

    // 금액 포맷팅 (천 단위 쉼표)
    String formattedRemainingBudget = remainingBudget.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},'
    );

    String formmatedTotalBudget = selectedBudget.budgetAmount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},'
    );

    // 하루 예산
    int dailyBudget = state.dailyBudget?.dailyBudgetAmount ?? 0;

    String formattedDailyBudget = dailyBudget.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},'
    );

    // 선택된 위시리스트 찾기 (isSelected가 'Y'인 항목)
    final selectedWishlist = wishlistState.wishlists
        .where((item) => item.isSelected == 'Y')
        .toList();

    return Scaffold(
      appBar: CustomAppbar(title: '남은 예산'),
      body: Column(
        children: [
          // 예산 정보 요약
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 좌측 : 전체 남은 예산
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: formattedRemainingBudget,
                        style: AppTextStyles.congratulation
                      ),
                      const TextSpan(
                        text: ' 원',
                        style: AppTextStyles.bodyMedium
                      ),
                    ],
                  ),
                ),
                // 우측: 총액과 하루 예산
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '예산 $formmatedTotalBudget 원',
                      style: AppTextStyles.bodyExtraSmall, 
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '오늘의 예산 $formattedDailyBudget 원',
                      style: AppTextStyles.bodyExtraSmall,
                    )
                  ],
                )
              ],
            ),
          ),

          // 날짜 범위 선택기
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    ref.read(budgetProvider.notifier).navigateToNextBudget();
                  }, 
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  state.dateRangeText,
                  style: AppTextStyles.bodySmall,
                ),
                IconButton(
                  onPressed: () {
                    ref.read(budgetProvider.notifier).navigateToPreviousBudget();
                  }, 
                  icon: const Icon(Icons.chevron_right)
                ),
              ],
            )
          ),

          // 메인 버블 차트 
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.0),
              child: categories.isNotEmpty
              ? BudgetBubblechart(categories: categories)
              : const Center(child: Text('등록된 예산이 없습니다')),
            ),
          ),

          // 위시 리스트 섹션
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(22.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '위시 리스트',
                    style: AppTextStyles.appBar,
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: wishlistState.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : wishlistState.errorMessage != null
                        ? Center(child: Text('위시 리스트를 불러오는 중 오류가 발생했습니다.'))
                        : selectedWishlist.isEmpty
                          ? const Center(child: Text('위시 리스트가 비어있습니다.'))
                          : _buildWishlistItem(context, selectedWishlist.first),
                  )
                ],
              )
            ),
          )
        ],
      )
    );
  }

  // 위시리스트 항목 위젯
  Widget _buildWishlistItem(BuildContext context, Wishlist wishlist) {
    // 가격 포맷팅
    String formattedPrice = wishlist.productPrice.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},'
    );

    // 예시로 일단 날짜는 고정값 사용 (실제로는 API 응답에서 받아와야 함)
    String createdDate = "2025-04-10";

    return InkWell(
      onTap: () {
        // 위시리스트 상세 페이지로 이동
        // context.push('/wishlist/detail/${wishlist.wishlistPk}');
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // 이미지 부분
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
                image: DecorationImage(
                  image: wishlist.productImageUrl != null
                      ? NetworkImage(wishlist.productImageUrl!)
                      : const AssetImage('assets/images/characters/char_hat.png') as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // 정보 부분
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.bookmark, size: 14, color: Colors.amber[700]),
                        const SizedBox(width: 4),
                        Text(
                          wishlist.productNickname,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      wishlist.productName,
                      style: AppTextStyles.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '등록일: $createdDate   목표액: $formattedPrice원',
                      style: AppTextStyles.bodyExtraSmall.copyWith(color: AppColors.disabled),
                    ),
                    const SizedBox(height: 8),
                    // 진행바 (임시로 50% 진행 표시)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: 0.5, // 실제로는 API에서 진행률 받아와야 함
                        backgroundColor: AppColors.whiteDark,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.bluePrimary),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}