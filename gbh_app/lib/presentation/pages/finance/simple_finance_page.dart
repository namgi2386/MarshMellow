// presentation/pages/finance/finance_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// import 'package:marshmellow/core/utils/lifecycle/app_lifecycle_manager.dart';
import 'package:marshmellow/presentation/widgets/custom_appbar/custom_appbar.dart';
import 'package:marshmellow/router/routes/finance_routes.dart';
// import 'package:marshmellow/presentation/viewmodels/finance/finance_viewmodel.dart';

// 분리한 위젯들 import
// import 'package:marshmellow/presentation/pages/finance/widgets/account_item_widget.dart';
// import 'package:marshmellow/presentation/pages/finance/widgets/card_item_widget.dart';
// import 'package:marshmellow/presentation/pages/finance/widgets/financial_section_widget.dart';
// import 'package:marshmellow/presentation/pages/finance/widgets/total_assets_widget.dart';

// appbar 간편버튼
import 'package:marshmellow/presentation/pages/finance/widgets/simple_toggle_button_widget.dart';


class SimpleFinancePage extends ConsumerWidget {
  const SimpleFinancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 라이프사이클 상태 구독
    // final lifecycleState = ref.watch(lifecycleStateProvider);

    // 뷰모델에서 데이터 가져오기
    // final assetData = ref.watch(assetDataProvider);

    return Scaffold(
      backgroundColor: Colors.tealAccent,
      appBar: CustomAppbar(
        title: 'my little 자산',
        actions: [
          const SimpleToggleButton(), // 분리한 커스텀 토글 버튼 위젯
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // 테스트 페이지로 이동
            ElevatedButton(
              onPressed: () {
                context.push(FinanceRoutes.getTestPath()); 
              },
              child: const Text('테스트 페이지로 이동'),
            ),
            // 간편 모드 상태 확인 텍스트
            Consumer(
              builder: (context, ref, child) {
                final isSimpleMode = ref.watch(simpleViewModeProvider);
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  color: isSimpleMode ? Colors.black12 : Colors.white70,
                  child: Center(
                    child: Text(
                      '현재 모드: ${isSimpleMode ? "간편 모드" : "일반 모드"}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSimpleMode ? Colors.blue : Colors.grey,
                      ),
                    ),
                  ),
                );
              },
            ),

          ],
        ),
      ),
    );
  }
}