// lib/router/routes/budget_routes.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:marshmellow/presentation/pages/budget/budget_page.dart';

class BudgetRoutes {
  static const String root = '/budget';
  // 추가 경로가 필요하면 여기에 정의
}

List<RouteBase> budgetRoutes = [
  GoRoute(
    path: BudgetRoutes.root,
    builder: (context, state) => const BudgetPage(),
    routes: [
      // 하위 라우트 추가 가능
    ],
  ),
];