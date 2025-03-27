import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart'; // 텍스트 스타일 import 추가
import 'package:marshmellow/core/theme/app_colors.dart'; // 테마 import 추가
import 'package:marshmellow/core/config/app_config.dart';
import 'package:marshmellow/core/utils/back_gesture/controller.dart';
import 'package:marshmellow/core/utils/back_gesture/detector.dart';
import 'package:marshmellow/router/app_router.dart'; // 라우터 import
import 'package:marshmellow/di/providers/lifecycle_provider.dart';
import 'package:marshmellow/presentation/widgets/datepicker/date_picker_overlay.dart';

class App extends ConsumerStatefulWidget {
  final GoRouter router;
  final BackGestureController backGestureController;

  const App(
      {super.key, required this.router, required this.backGestureController});

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
    return MaterialApp.router(
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
        routerConfig: widget.router,
        // 스와이프 뒤로가기 제스처 감지 추가
        builder: (context, child) {
          return DatePickerOverlay(
            child: SwipeBackDetector(
              controller: widget.backGestureController,
              router: widget.router,
              child: child!,
            ),
          );
        });
  }
}
