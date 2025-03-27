import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marshmellow/router/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'package:marshmellow/core/utils/back_gesture/controller.dart';

// 환경설정 import
import 'core/config/environment_loader.dart';
import 'di/providers/core_providers.dart';
import 'app.dart';

// Hive 서비스 (새로 추가)
class HiveService {
  // Hive 초기화 메서드
  static Future<void> init() async {
    try {
      // 앱의 로컬 문서 디렉토리 경로 가져오기
      final appDocumentDir = await getApplicationDocumentsDirectory();

      // Hive 초기화 및 저장 경로 설정
      await Hive.initFlutter(appDocumentDir.path);

      // 필요한 Box 미리 열어두기
      await Hive.openBox('searchHistory');

      // 필요하다면 다른 Hive 어댑터 등록
      // Hive.registerAdapter(MyModelAdapter());

      if (kDebugMode) {
        print('Hive 초기화 성공');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Hive 초기화 실패: $e');
      }
    }
  }

  // 모든 Hive 박스 닫기 (앱 종료 시 사용 가능)
  static Future<void> closeBoxes() async {
    await Hive.close();
  }
}

Future<void> main() async {
  // 위젯 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // 환경 설정 로드
  await EnvironmentLoader.load();

  // Hive 초기화
  await HiveService.init();

  // SharedPreferences 초기화 - 에러 방지를 위한 조건부 초기화
  SharedPreferences? sharedPreferences;
  try {
    sharedPreferences = await SharedPreferences.getInstance();
  } catch (e) {
    // 디버그 모드에서만 로그 출력
    if (kDebugMode) {
      print('SharedPreferences 초기화 실패: $e');
    }
  }

  // 뒤로가기 제스처 컨트롤러 생성
  final backGestureController = BackGestureController();

  // 뒤로가기 제스처 관리 포함된 라우터 생성
  final router = createRouter(backGestureController);

  // Override 프로바이더를 사용하여 초기화된 인스턴스 제공
  runApp(
    ProviderScope(
      overrides: [
        // 초기화된 SharedPreferences 인스턴스로 오버라이드
        // null일 수 있으므로 조건부 오버라이드
        if (sharedPreferences != null)
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: App(
        router: router,
        backGestureController: backGestureController,
      ),
    ),
  );
}
