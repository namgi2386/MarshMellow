import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/presentation/pages/auth/widgets/etc/custom_complete.dart';
import 'package:marshmellow/router/routes/auth_routes.dart';

/*
  핀넘버 설정 성공 UI
*/
class AuthPinnumCompletePage extends StatelessWidget {
  const AuthPinnumCompletePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    Future.delayed(const Duration(seconds: 2), () {
      context.go(SignupRoutes.getMyDataSplashPath());
    });
    return MaterialApp(
      home: buildBlueWidget(),
    );
  }

  Widget buildBlueWidget() {
    return const CustomComplete(
      backgroundColor: AppColors.bluePrimary, 
      message: 'PIN번호 설정 완료!'
    );
  }
}