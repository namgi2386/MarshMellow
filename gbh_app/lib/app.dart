import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart'; // 텍스트 스타일 import 추가
import 'package:marshmellow/core/theme/app_colors.dart'; // 테마 import 추가
import 'package:marshmellow/main.dart';
import 'package:marshmellow/presentation/widgets/bottom_navbar/bottom_navbar_logic.dart';
import 'core/config/app_config.dart';

import 'di/providers/lifecycle_provider.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  void initState() {
    super.initState();
    // 라이프사이클 매니저 초기화 - 프로바이더를 읽는 것만으로 초기화됨
    ref.read(appLifecycleManagerProvider);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MMApp',
      debugShowCheckedModeBanner: AppConfig.isDevelopment(),
      theme: ThemeData(
        primaryColor: AppColors.background,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: AppTextStyles.fontFamily,
        textTheme: TextTheme(
          bodyLarge: AppTextStyles.bodyLarge,
          titleLarge: AppTextStyles.appBar,
        ),
        useMaterial3: true,
      ),
      home: const MainNavigator(),
    );
  }
}
