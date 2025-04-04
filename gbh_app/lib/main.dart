import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marshmellow/router/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'package:marshmellow/core/utils/back_gesture/controller.dart';
import 'package:marshmellow/core/services/transaction_classifier_service.dart';

// 환경설정 import
import 'core/config/environment_loader.dart';
import 'di/providers/core_providers.dart';
import 'app.dart';

/// Hive 서비스
class HiveService {
  /// Hive 초기화
  static Future<void> init() async {
    try {
      final appDocumentDir = await getApplicationDocumentsDirectory();

      await Hive.initFlutter(appDocumentDir.path);
      await Hive.openBox('searchHistory');

      if (kDebugMode) {
        print('Hive 초기화 성공');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Hive 초기화 실패: $e');
      }
    }
  }

  /// Hive 박스 전체 닫기
  static Future<void> closeBoxes() async {
    await Hive.close();
  }
}

Future<void> main() async {
  // 초기화 단계
  WidgetsFlutterBinding.ensureInitialized();

  // 환경 설정 및 서비스 초기화
  await Future.wait([EnvironmentLoader.load(), HiveService.init()]);

  // SharedPrefer33es 초기화 (옵셔널)
  SharedPreferences? sharedPreferences = await _initSharedPreferences();

  // 백 제스처 및 라우터 설정
  final backGestureController = BackGestureController();
  final router = createRouter(backGestureController);

  // 트랜잭션 동기화 수행
  await _performTransactionSync();

  // 앱 실행
  runApp(
    ProviderScope(
      overrides: [
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

/// SharedPreferences 초기화
Future<SharedPreferences?> _initSharedPreferences() async {
  try {
    return await SharedPreferences.getInstance();
  } catch (e) {
    if (kDebugMode) {
      print('❌ SharedPreferences 초기화 실패: $e');
    }
    return null;
  }
}

/// 트랜잭션 동기화 수행
Future<void> _performTransactionSync() async {
  final container = ProviderContainer();
  final syncService = container.read(transactionSyncServiceProvider);

  try {
    // 미분류 내역 확인
    if (kDebugMode) {
      print('🔄 미분류 거래 내역 확인 중...');
    }

    final hasUnsortedTransactions = await syncService.hasUnsortedTransactions();

    if (hasUnsortedTransactions) {
      if (kDebugMode) {
        print('🔄 미분류 거래 내역 동기화 시작');
      }

      final syncResult = await syncService.performFullSync();

      if (kDebugMode) {
        print(
            '🔄 미분류 내역 동기화 결과: ${syncResult.success ? '성공' : '실패'} - ${syncResult.message}');
        print('📊 동기화된 거래 내역 수: ${syncResult.totalTransactions}');
      }
    } else {
      if (kDebugMode) {
        print('✅ 미분류 거래 내역 없음');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print('❌ 트랜잭션 동기화 중 오류 발생: $e');
    }
  } finally {
    container.dispose();
  }
}
