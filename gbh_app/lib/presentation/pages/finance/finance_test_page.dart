// lib/presentation/pages/finance/finance_test_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; 

import 'package:go_router/go_router.dart'; // 이제 라우트 할거면 필수
import 'package:marshmellow/router/routes/finance_routes.dart'; // 경로 상수 import

class FinanceTestPage extends StatelessWidget {
  const FinanceTestPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finance Test Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('이것은 Finance 테스트 페이지입니다'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.pop(); // 이전 페이지로 돌아가기
              },
              child: const Text('돌아가기'),
            ),
// <<<<<<<<<<<<<<<<<<<<<<<<<<<< 키보드 테스트 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 테스트 페이지로 이동
                context.push(FinanceRoutes.getKeyboardTestPath());
              },
              child: const Text('키보드 테스트'),
            ),
// >>>>>>>>>>>>>>>>>>>>>>>>>>>>> 키보드 테스트 >>>>>>>>>>>>>>>>>>>>>>>>>>>>
          ],
        ),
      ),
    );
  }
}