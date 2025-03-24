// lib/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// 메인 레이아웃을 관리할 위젯 import
import 'package:marshmellow/router/scaffold_with_nav_bar.dart';
// 각 탭 라우트 파일 import
import 'routes/ledger_routes.dart';
import 'routes/finance_routes.dart';
import 'routes/budget_routes.dart';
import 'routes/cookie_routes.dart';
import 'routes/my_routes.dart';
import 'routes/etc/notification_routes.dart';
import 'routes/auth_routes.dart';

// 라우터 설정
final goRouter = GoRouter(
  initialLocation: BudgetRoutes.root,
  debugLogDiagnostics: true, // 개발 중에는 디버그 모드 활성화
  // 루트 경로에 대한 리다이렉트 추가
  redirect: (context, state) {
    if (state.matchedLocation == '/') {
      return BudgetRoutes.root; // 원하는 기본 경로로 리다이렉트
    }
    return null; // 다른 경로는 정상 처리
  },
  routes: [
    // 쉘 라우트 - 하단 네비게이션 바를 포함한 레이아웃
    ShellRoute(
      builder: (context, state, child) {
        return ScaffoldWithNavBar(child: child);
      },
      routes: [
        ...ledgerRoutes,
        ...financeRoutes,
        ...budgetRoutes,
        ...cookieRoutes,
        ...myRoutes,
        ...notificationRoutes,
      ],
    ),
    ...signupRoutes,
  ],
);