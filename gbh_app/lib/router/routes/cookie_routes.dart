// lib/router/routes/cookie_routes.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:marshmellow/presentation/pages/cookie/cookie_page.dart';

class CookieRoutes {
  static const String root = '/cookie';
  // 추가 경로가 필요하면 여기에 정의
}

List<RouteBase> cookieRoutes = [
  GoRoute(
    path: CookieRoutes.root,
    builder: (context, state) => const CookiePage(),
    routes: [
      // 하위 라우트 추가 가능
    ],
  ),
];