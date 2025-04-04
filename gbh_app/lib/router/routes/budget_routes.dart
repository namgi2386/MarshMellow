// lib/router/routes/budget_routes.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:marshmellow/data/models/budget/budget_model.dart';
import 'package:marshmellow/presentation/pages/budget/budget_page.dart';
import 'package:marshmellow/presentation/pages/budget/widgets/budget_detail/budget_category_detail_page.dart';
import 'package:marshmellow/presentation/pages/budget/widgets/budget_detail/category_expense_list_page.dart';

/*
  예산 routes
*/
class BudgetRoutes {
  static const String root = '/budget';
  static const String budgetdetail = 'detail/:budgetPk';
  static const String budgetcategoryexpense = 'category/expenses/:categoryPk';
  // 추가 경로가 필요하면 여기에 정의

  // 전체 경로 생성 헬퍼 메서드
  static String getBudgetDetailPath() => '$root/$budgetdetail';
  static String getBudgetCategoryExpensePath() => '$root/$budgetcategoryexpense';
}

List<RouteBase> budgetRoutes = [
  GoRoute(
    path: BudgetRoutes.root,
    builder: (context, state) => const BudgetPage(),
    routes: [
      // 예산 상세 페이지 : 모든 카테고리
      GoRoute(
        path: BudgetRoutes.budgetdetail,
        builder: (context, state) {
          final budgetPk = int.parse(state.pathParameters['budgetPk']!);
          return BudgetCategoryDetailPage(budgetPk: budgetPk);
        },
      ),

      // 예산 카테고리별 지출 상세 페이지
      GoRoute(
        path: BudgetRoutes.budgetcategoryexpense,
        builder: (context, state) {
          final categoryPk = int.parse(state.pathParameters['categoryPk']!);
      
          // Extra data contains the category model and budgetPk
          final extra = state.extra as Map<String, dynamic>;
          final category = extra['category'] as BudgetCategoryModel;
          final budgetPk = extra['budgetPk'] as int;
          return CategoryExpensePage(categoryPk: categoryPk, category: category, budgetPk: budgetPk);
        },
      ),

    ],
  ),
];