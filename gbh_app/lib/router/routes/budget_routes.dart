// lib/router/routes/budget_routes.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:marshmellow/presentation/pages/budget/budget_page.dart';

/*
  예산 routes
*/
class BudgetRoutes {
  static const String root = '/budget';
  static const String signuptest = 'signuptest';
  // 추가 경로가 필요하면 여기에 정의

  // 전체 경로 생성 헬퍼 메서드
  static String getSignUpTestPath() => '$root/$signuptest';
}

List<RouteBase> budgetRoutes = [
  GoRoute(
    path: BudgetRoutes.root,
    builder: (context, state) => const BudgetPage(),
    routes: [

    ],
  ),
];