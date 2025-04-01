// lib/router/routes/cookie_routes.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:marshmellow/presentation/pages/cookie/cookie_page.dart';
import 'package:marshmellow/presentation/pages/cookie/lunch_page.dart';
import 'package:marshmellow/presentation/pages/cookie/quit_page.dart';
import 'package:marshmellow/presentation/pages/cookie/portfolio_page.dart';

class CookieRoutes {
  static const String root = '/cookie';
  // 추가 경로가 필요하면 여기에 정의
  static const String lunch = 'lunch';
  static const String quit = 'quit';
  static const String portfolio = 'portfolio';

  static String getLunchPath() => '$root/$lunch';
  static String getQuitPath() => '$root/$quit';
  static String getPortfolioPath() => '$root/$portfolio';
}

List<RouteBase> cookieRoutes = [
  GoRoute(
    path: CookieRoutes.root,
    builder: (context, state) => const CookiePage(),
    routes: [
      GoRoute(
        path: 'lunch',
        builder: (context, state) => const LunchPage(),
      ),
      GoRoute(
        path: 'quit',
        builder: (context, state) => const QuitPage(),
      ),
      GoRoute(
        path: 'portfolio',
        builder: (context, state) => const PortfolioPage(),
      ),
    ],
  ),
];
