// lib/router/routes/finance_routes.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:marshmellow/presentation/pages/finance/finance_page.dart';
import 'package:marshmellow/presentation/pages/finance/finance_test_page.dart';
import 'package:marshmellow/presentation/pages/testpage/keyboard_test_page.dart'; // 추가

class FinanceRoutes {
  static const String root = '/finance';
  static const String test = 'financetest'; // 하위 경로 추가
  static const String keyboardtest = 'keyboardtest'; // 하위 경로 추가
  
  // 전체 경로 생성 헬퍼 메서드
  static String getTestPath() => '$root/$test'; // 전체 경로 반환 헬퍼
  static String getKeyboardTestPath() => '$root/$keyboardtest'; // 전체 경로 반환 헬퍼
}

List<RouteBase> financeRoutes = [
  GoRoute(
    path: FinanceRoutes.root,
    builder: (context, state) => const FinancePage(),
    routes: [
      // 테스트 하위 라우트 추가
      GoRoute(
        path: FinanceRoutes.test,
        builder: (context, state) => const FinanceTestPage(),
      ),
      GoRoute(
        path: FinanceRoutes.keyboardtest,
        builder: (context, state) => const KeyboardTestPage(),
      ),
    ],
  ),
];