// lib/router/routes/my_routes.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:marshmellow/presentation/pages/my/my_page.dart';


import 'package:marshmellow/presentation/pages/testpage/datepickertest.dart';
import 'package:marshmellow/presentation/widgets/datepicker/date_picker_overlay.dart';

class MyRoutes {
  static const String root = '/my';
  static const String datepickerTest = 'datepicker-test';
  
  // 전체 경로 생성 헬퍼 메서드
  static String getDatepickerTestPath() => '$root/$datepickerTest'; // 전체경로의 형태
}

List<RouteBase> myRoutes = [
  GoRoute(
    path: MyRoutes.root,
    builder: (context, state) => const MyPage(),
    routes: [
      GoRoute(
        path: MyRoutes.datepickerTest,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            child: DatePickerOverlay(
              child: const Datepickertest(),
            ), 
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation, 
                child: child,
              );
            }
          );
        }
      )
    ],
  ),
];