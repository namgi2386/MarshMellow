// lib/router/routes/finance_routes.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:marshmellow/presentation/pages/finance/detail/demand_detail_page.dart';
import 'package:marshmellow/presentation/pages/finance/detail/deposit_detail_page.dart';
import 'package:marshmellow/presentation/pages/finance/finance_page.dart';
import 'package:marshmellow/presentation/pages/finance/finance_test_page.dart';
import 'package:marshmellow/presentation/pages/finance/finance_transfer_page.dart';
import 'package:marshmellow/presentation/pages/finance/simple_finance_page.dart';
import 'package:marshmellow/presentation/pages/testpage/keyboard_test_page.dart'; // 추가

class FinanceRoutes {
  static const String root = '/finance';
  static const String test = 'financetest'; // 하위 경로 추가
  static const String keyboardtest = 'keyboardtest'; // 하위 경로 추가
  static const String rootsimple = 'simple'; // 하위 경로 추가
  static const String transfer = 'transfer'; // 하위 경로 추가
  static const String demandDetail = 'account/demand/:accountNo'; // 입출금계좌 상세 경로
  static const String depositDetail = 'account/deposit/:accountNo'; // 예금계좌 상세 경로
  static const String savingDetail = 'account/saving/:accountNo'; // 적금계좌 상세 경로
  static const String loanDetail = 'account/loan/:accountNo'; // 대출계좌 상세 경로
  static const String cardDetail = 'card/:cardNo'; // 카드계좌 상세 경로
  
  // 전체 경로 생성 헬퍼 메서드
  static String getTestPath() => '$root/$test'; // 전체 경로 반환 헬퍼
  static String getKeyboardTestPath() => '$root/$keyboardtest'; // 전체 경로 반환 헬퍼
  static String getSimplePath() => '$root/$rootsimple'; // 전체 경로 반환 헬퍼
  static String getTransferPath() => '$root/$transfer'; // 전체 경로 반환 헬퍼
  static String getDemandDetailPath(String accountNo) => '$root/account/demand/$accountNo'; // 입출금계좌 상세 경로
  static String getDepositDetailPath(String accountNo) => '$root/account/deposit/$accountNo'; // 예금계좌 상세 경로
  static String getSavingDetailPath(String accountNo) => '$root/account/saving/$accountNo'; // 적금계좌 상세 경로
  static String getLoanDetailPath(String accountNo) => '$root/account/loan/$accountNo'; // 대출계좌 상세 경로
  static String getCardDetailPath(String cardNo) => '$root/card/$cardNo'; // 카드계좌 상세 경로
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
      GoRoute(
        path: FinanceRoutes.rootsimple,
        builder: (context, state) => const SimpleFinancePage(),
      ),
      GoRoute(
        path: FinanceRoutes.transfer,
        builder: (context, state) => const FinanceTransferPage(),
      ),
      GoRoute(
        path: FinanceRoutes.demandDetail,
        builder: (context, state) {
          final accountNo = state.pathParameters['accountNo'] ?? '';
          final extra = state.extra as Map<String, dynamic>?;
          
          return DemandDetailPage(
            accountNo: accountNo,
            bankName: extra?['bankName'] ?? '',
            accountName: extra?['accountName'] ?? '',
            balance: extra?['balance'] ?? 0,
            noMoneyMan: extra?['noMoneyMan'] ?? false,
          );
        },
      ),
      GoRoute(
        path: FinanceRoutes.depositDetail,
        builder: (context, state) {
          final accountNo = state.pathParameters['accountNo'] ?? '';
          final extra = state.extra as Map<String, dynamic>?;
          
          return DepositDetailPage(
            accountNo: accountNo,
            bankName: extra?['bankName'] ?? '',
            accountName: extra?['accountName'] ?? '',
            balance: extra?['balance'] ?? 0,
            noMoneyMan: extra?['noMoneyMan'] ?? false,
          );
        },
      ),
    ],
  ),
];