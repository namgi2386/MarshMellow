import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marshmellow/core/config/app_config.dart';
import 'package:marshmellow/core/utils/lifecycle/app_lifecycle_manager.dart'; // 추가
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/presentation/pages/testpage/datepickertest.dart'; // 이 줄 추가
import 'package:marshmellow/presentation/widgets/datepicker/date_picker_overlay.dart';

class MyPage extends ConsumerWidget {
  const MyPage({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 라이프사이클 상태 구독
    final lifecycleState = ref.watch(lifecycleStateProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('마이마이!'),
        titleTextStyle: AppTextStyles.appBar,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '환경 설정 테스트3',
              style: AppTextStyles.mainTitle,
            ),
            // CounterPage(),
            const SizedBox(height: 20),
            Text(
              '현재 환경: ${AppConfig.isDevelopment() ? "개발" : "프로덕션"}',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 10),
            // 라이프사이클 상태 표시 추가
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '라이프사이클 상태: $lifecycleState',
                style: AppTextStyles.subTitle,
              ),
            ),
            Text(
              'API URL: ${AppConfig.apiBaseUrl}',
              style: AppTextStyles.bodyExtraSmall,
            ),
            // 서비스 로케이터 테스트를 위한 버튼 추가
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                print("tt");
                // 서비스 로케이터가 제대로 설정되었는지 확인
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('의존성 주입 테스트 성공')),
                );
              },
              child: const Text('의존성 주입 테스트', style: AppTextStyles.button),
            ),
            const SizedBox(height: 20), // 남기 datepicker 테스트페이지
            ElevatedButton(
              onPressed: () {
                // 직접 테스트 페이지로 이동
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => DatePickerOverlay(
                    child: const Datepickertest(),
                  ),),
                );
              },
              child: const Text('테스트 페이지로 이동'),
            ),
          ],
        ),
      ),
    );
  }
}
