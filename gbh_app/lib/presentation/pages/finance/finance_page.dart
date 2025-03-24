import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marshmellow/core/utils/lifecycle/app_lifecycle_manager.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/presentation/widgets/custom_appbar/custom_appbar.dart';

// <<<<<<<<<<<<<<<<<<<<<<<<<<<< 라우터 테스트 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
import 'package:go_router/go_router.dart'; // 이제 라우트 할거면 필수
import 'package:marshmellow/router/routes/finance_routes.dart'; // 경로 상수 import
// >>>>>>>>>>>>>>>>>>>>>>>>>>>>> 라우터 테스트 >>>>>>>>>>>>>>>>>>>>>>>>>>>>

// <<<<<<<<<<<<<<<<<<<<<<<<<<<< API 자산조회 테스트 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
import 'package:marshmellow/data/datasources/remote/finance_api.dart';
final assetDataProvider = FutureProvider<dynamic>((ref) async {
  final financeApi = ref.watch(financeApiProvider);
  // 테스트용 고정 userKey 사용
  return await financeApi.getAssetInfo("2c2fd595-4118-4b6c-9fd7-fc811910bb75");
});
// >>>>>>>>>>>>>>>>>>>>>>>>>>>>> API 자산조회 테스트 >>>>>>>>>>>>>>>>>>>>>>>>>>>>

class FinancePage extends ConsumerWidget {
  const FinancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 라이프사이클 상태 구독
    final lifecycleState = ref.watch(lifecycleStateProvider);

// <<<<<<<<<<<<<<<<<<<<<<<<<<<< API 자산조회 테스트 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    final assetData = ref.watch(assetDataProvider);
// >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> API 자산조회 테스트 >>>>>>>>>>>>>>>>>>>>>>>>>>>>

    return Scaffold(

      appBar: CustomAppbar(
        title: '자산',
        actions: [
          // 추가할 아이콘
          IconButton(
            icon: const Icon(Icons.stacked_bar_chart_rounded),
            onPressed: () {
              // 추가할 기능
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
        // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< 라우터 테스트 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 테스트 페이지로 이동
                context.push(FinanceRoutes.getTestPath());
              },
              child: const Text('테스트 페이지로 이동'),
            ),
        // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 라우터 테스트 >>>>>>>>>>>>>>>>>>>>>>>>>>>>
        
        // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< API 자산조회 테스트 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
            Expanded(
              child: assetData.when(
                data: (data) {
                  // 성공적으로 데이터를 받았을 때
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '자산 정보:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        // 받아온 데이터를 텍스트로 표시 (디버깅용)
                        Text(data.toString()),
                      ],
                    ),
                  );
                },
                loading: () => const CircularProgressIndicator(),
                error: (error, stackTrace) {
                  // 에러 발생 시
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 10),
                      Text('에러 발생: $error'),
                      ElevatedButton(
                        onPressed: () => ref.refresh(assetDataProvider),
                        child: const Text('다시 시도'),
                      ),
                    ],
                  );
                },
              ),
            ),
        // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> API 자산조회 테스트 >>>>>>>>>>>>>>>>>>>>>>>>>>>>
          ],
        ),
      ),
    );
  }
}
