import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/config/app_config.dart';

// SharedPreferences 프로바이더
// 초기화가 필요한 인스턴스를 저장할 StateProvider 생성
final sharedPreferencesProvider = Provider<SharedPreferences?>((ref) {
  // null로 초기화하고 나중에 main.dart에서 오버라이드
  return null;
});

// SecureStorage 프로바이더 : const 생성자로 간단히 초기화
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

// Dio 프로바이더 : 기본 설정 및 타임아웃, 헤더, 로그 인터셉터까지 모두 설정됨
// (수정해야됨)(수정해야됨)(수정해야됨)(수정해야됨)(수정해야됨)(수정해야됨)(수정해야됨)
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: AppConfig.apiBaseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    sendTimeout: const Duration(seconds: 15),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));
  
  if (AppConfig.debugMode) {
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }
  
  return dio;
});

// Hive 프로바이더 (필요하다면 추가)
// final hiveProvider = Provider<HiveInterface>((ref) {
//   return Hive;
// });

// 사용 예시
/*
final someProvider = Provider<SomeService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  // null 체크 추가
  if (prefs == null) {
    throw Exception('SharedPreferences가 초기화되지 않았습니다');
  }
  return SomeService(prefs);
});
*/