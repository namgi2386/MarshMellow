// lib/presentation/pages/finance/finance_test_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; 

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
          ],
        ),
      ),
    );
  }
}