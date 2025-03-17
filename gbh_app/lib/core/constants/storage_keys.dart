// 로컬 저장소 키 상수 정의
class StorageKeys {
  // SharedPreferences 키
  static const String AUTH_TOKEN = 'auth_token';
  static const String REFRESH_TOKEN = 'refresh_token';
  static const String USER_ID = 'user_id';
  static const String USER_NAME = 'user_name';
  static const String IS_LOGGED_IN = 'is_logged_in';
  static const String LAST_LOGIN_TIME = 'last_login_time';
  static const String APP_THEME = 'app_theme';
  static const String LANGUAGE_CODE = 'language_code';
  
  // Secure Storage 키
  static const String ENCRYPTED_PIN = 'encrypted_pin';
  static const String PRIVATE_KEY = 'private_key';
  static const String CERTIFICATE = 'certificate';
  
  // Hive Box 이름
  static const String USER_BOX = 'user_box';
  static const String SETTINGS_BOX = 'settings_box';
  static const String TRANSACTION_BOX = 'transaction_box';
}

// 사용 예시

/*

import 'package:test0316_1/core/constants/storage_keys.dart';

// SharedPreferences 사용시
final prefs = await SharedPreferences.getInstance();
final token = prefs.getString(StorageKeys.AUTH_TOKEN);

// Secure Storage 사용시
final storage = FlutterSecureStorage();
await storage.write(key: StorageKeys.ENCRYPTED_PIN, value: encryptedPin);

*/