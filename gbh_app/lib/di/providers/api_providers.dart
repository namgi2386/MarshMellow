import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/api_client.dart';
import 'core_providers.dart';

// API 클라이언트 프로바이더
final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiClient(dio);
});
