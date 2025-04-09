import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:marshmellow/router/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:marshmellow/core/utils/back_gesture/controller.dart';
import 'package:marshmellow/core/services/transaction_classifier_service.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

// 환경설정 import
import 'core/config/environment_loader.dart';
import 'di/providers/core_providers.dart';
import 'app.dart';

// Firebase 관련 import
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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

  // Flutter Downloader 초기화
  await FlutterDownloader.initialize(
    debug: true, // 디버그 모드 (로그 출력)
    ignoreSsl: true, // SSL 검증 무시
  );

  // Firebase 초기화
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await initLocalNotification(); // 로컬 알림 초기화
  setupFCM(); // FCM 설정 함수 호출

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

/// ✅ FCM 설정 함수
final _firebaseMessaging = FirebaseMessaging.instance;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// 📱 알림 채널 설정 (Android)
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // 이름
  description: 'This channel is used for important notifications.',
  importance: Importance.high,
  playSound: true,
);

/// 📦 백그라운드 메시지 핸들러
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  _showLocalNotification(message);
}

/// 🔔 로컬 알림 띄우기
void _showLocalNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = message.notification?.android;

  if (notification != null && android != null) {
    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: channel.importance,
          priority: Priority.high,
          playSound: true,
          icon: android.smallIcon,
        ),
      ),
    );
  }
}

// FCM
void setupFCM() async {
  // 알림 권한 요청 (iOS & Android 13+)
  NotificationSettings settings = await _firebaseMessaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    if (kDebugMode) print('✅ 알림 권한 허용됨');
  } else {
    if (kDebugMode) print('❌ 알림 권한 거부됨');
  }

  // 토큰 확인 메서드 회원가입시 이걸 서버에 보내야함
  String? token = await _firebaseMessaging.getToken();
  if (kDebugMode) print("📱 FCM Token: $token");

  // 토큰 새로 갱신될 때
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    if (kDebugMode) print('🔄 토큰 갱신됨: $newToken');
  });

  // 포그라운드 메시지 수신
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('📩 Foreground message: ${message.notification?.title}');
    _showLocalNotification(message);
  });

  // 백그라운드에서 앱을 열었을 때
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('🔔 Background opened message: ${message.notification?.title}');
    // _showLocalNotification(message);
    // 원하는 페이지로 이동하는 코드 추가 // 예: Navigator.pushNamed(context, '/notificationPage');
  });
}

/// ✅ 로컬 알림 초기화
Future<void> initLocalNotification() async {
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_stat_notification');

  const InitializationSettings initSettings = InitializationSettings(
    android: androidSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}
