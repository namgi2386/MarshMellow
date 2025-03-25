// lib/router/routes/signup_routes.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:marshmellow/presentation/pages/auth/widgets/mydata/auth_mydata_page.dart';
import 'package:marshmellow/presentation/pages/auth/widgets/pinnum/auth_pinnum_complete_page.dart';
import 'package:marshmellow/presentation/pages/auth/signup_page.dart';
import 'package:marshmellow/presentation/pages/auth/widgets/message/auth_message_page.dart';
import 'package:marshmellow/presentation/pages/auth/widgets/pinnum/auth_pinnum_page.dart';
import 'package:marshmellow/presentation/pages/auth/widgets/message/auth_message_verification_loading_page.dart';
import 'package:marshmellow/presentation/pages/auth/widgets/message/auth_message_complete_page.dart';

class SignupRoutes {
  static const String root = '/signup';
  // 추가 경로가 필요하면 여기에 정의
  static const String authmessage = 'authmessage';
  static const String authloading = 'authloading';
  static const String authcomplete = 'authcomplete';
  static const String pinsetup = 'pinsetup';
  static const String pincomplete = 'pincomplete';
  static const String mydatasetup = 'mydatasetup';

  // 전체 경로 생성 헬퍼 메서드
  static String getAuthMessagePath() => '$root/$authmessage';
  static String getAuthLoadingPath() => '$root/$authloading';
  static String getAuthCompletePath() => '$root/$authcomplete';
  static String getPinSetupPath() => '$root/$pinsetup';
  static String getPinCompletePath() => '$root/$pincomplete';
  static String getMyDataSetupPath() => '$root/$mydatasetup';
}

List<RouteBase> signupRoutes = [
  GoRoute(
    path: SignupRoutes.root,
    builder: (context, state) => const SignupPage(),
    routes: [
      // 인증 메시지 페이지
      GoRoute(
        path: SignupRoutes.authmessage,
        builder: (context, state) {
          final Map<String, dynamic> extra = state.extra as Map<String, dynamic>;
          return AuthMessagePage(
            name: extra['name'] as String,
            idNum: extra['idNum'] as String,
            phone: extra['phone'] as String,
            carrier: extra['carrier'] as String,
          );
        },
      ),

      // 본인인증 진행중 페이지
      GoRoute(
        path: SignupRoutes.authloading,
        builder: (context, state) => const AuthVerificationLoadingPage(),
      ),
      
      // 본인인증 완료 페이지
      GoRoute(
        path: SignupRoutes.authcomplete,
        builder: (context, state) => const AuthCompletePage(),
      ),

      // 핀번호 생성 페이지
      GoRoute(
        path: SignupRoutes.pinsetup,
        builder: (context, state) => const AuthPinnumPage(),
      ),

      // 핀번호 완료 페이지
      GoRoute(
        path: SignupRoutes.pincomplete,
        builder: (context, state) => const AuthPinnumCompletePage(),
      ),


    ],
  ),
];
