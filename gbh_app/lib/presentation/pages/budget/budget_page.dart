import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marshmellow/core/config/app_config.dart';
import 'package:marshmellow/core/utils/lifecycle/app_lifecycle_manager.dart'; // 추가
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/main.dart';
import 'package:marshmellow/presentation/pages/budget/widgets/budget_bubble_chart.dart';
import 'package:marshmellow/presentation/viewmodels/budget/budget_viewmodel.dart';
import 'package:marshmellow/presentation/widgets/custom_appbar/custom_appbar.dart';
import 'package:go_router/go_router.dart';
import 'package:marshmellow/router/routes/auth_routes.dart'; 
import 'package:marshmellow/router/routes/budget_routes.dart'; 

class BudgetPage extends ConsumerWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(budgetProvider);

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
          child: Text('선택된 예산이 없습니다다')
        ),
      );
    }

    final categories = selectedBudget.budgetCategoryList;
    final remainingBudget = state.remainingBudget;

    // 금액 포맷팅 (천 단위 쉼표)
    String formattedRemainingBudget = remainingBudget.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},'
    );

    return Scaffold(
      appBar: CustomAppbar(title: '남은 예산 $remainingBudget 원'),
      body: Column(
        children: [
          // 날짜 범위 선택기
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    ref.read(budgetProvider.notifier).navigateToPreviousBudget();
                  }, 
                  icon: Icon(Icons.chevron_left),
                ),
                Text(
                  state.dateRangeText,
                  style: AppTextStyles.bodySmall,
                ),
                IconButton(
                  onPressed: () {
                    ref.read(budgetProvider.notifier).navigateToNextBudget();
                  }, 
                  icon: Icon(Icons.chevron_right)
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
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '위시 리스트',
                    style: AppTextStyles.bodyMediumLight,
                  ),
                  const SizedBox(height: 12),
                  Expanded(child: Center(child: Text('위시 리스트가 비어있습니다.'),))
                ],
              )
            ),
          )
        ],
      )
    );



  }
}
