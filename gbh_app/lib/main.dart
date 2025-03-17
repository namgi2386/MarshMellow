import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

// 환경설정 import
import 'core/config/environment_loader.dart';
import 'di/providers/core_providers.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 환경 설정 로드
  await EnvironmentLoader.load();

  // Hive 초기화 - 로컬 데이터베이스 초기화
  // Hive는 비동기 초기화가 필요함
  try {
    await Hive.initFlutter(); // Hive 초기화 추가
    // 여기에 필요한 Hive 어댑터 등록 가능
    // Hive.registerAdapter(MyModelAdapter());
  } catch (e) {
    if (kDebugMode) {
      print('Hive 초기화 실패: $e');
    }
  }

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

  // Override 프로바이더를 사용하여 초기화된 인스턴스 제공
  runApp(
    ProviderScope(
      overrides: [
        // 초기화된 SharedPreferences 인스턴스로 오버라이드
        // null일 수 있으므로 조건부 오버라이드
        if (sharedPreferences != null)
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const App(),
    ),
  );
}