import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marshmellow/data/datasources/remote/auth_api.dart';
import 'package:marshmellow/data/datasources/remote/certificate_api.dart';
import '../../data/datasources/remote/api_client.dart';
import 'core_providers.dart';

// API 클라이언트 프로바이더
final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiClient(dio);
});

// Auth API 프로바이더
final authApiProvider = Provider<AuthApi>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthApi(dio);
});

// mm인증서 API 프로바이더
final certificateApiProvider = Provider<CertificateApi>((ref) {
  final dio = ref.watch(dioProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  return CertificateApi(dio, secureStorage);
});