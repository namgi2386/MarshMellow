import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/config/app_config.dart';

// SharedPreferences 프로바이더
final sharedPreferencesProvider = Provider<SharedPreferences?>((ref) {
  // null로 초기화하고 나중에 main.dart에서 오버라이드
  return null;
});

// SecureStorage 프로바이더
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

// Dio 프로바이더
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
    validateStatus: (status) {
      return status! < 500; // 서버 에러만 예외 처리
    },
  ));
  
  // 응답 인터셉터 추가 - 백엔드 커스텀 상태 코드 처리
  dio.interceptors.add(InterceptorsWrapper(
    onResponse: (response, handler) {
      // 응답에서 실제 상태 코드 확인 (response.data.status)
      if (response.data is Map && response.data['status'] != null) {
        final statusCode = response.data['status'];
        // 성공 상태 코드 범위 확인 (예: 200~299)
        if (statusCode < 200 || statusCode >= 300) {
          // 에러 응답으로 변환
          return handler.reject(
            DioException(
              requestOptions: response.requestOptions,
              response: response,
              error: '백엔드 에러: 상태 코드 ${response.data['status']}',
            ),
          );
        }
      }
      return handler.next(response);
    },
  ));
  
  // 디버그 모드일 때만 로그 인터셉터 추가
  if (AppConfig.debugMode) {
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }
  
  return dio;
});