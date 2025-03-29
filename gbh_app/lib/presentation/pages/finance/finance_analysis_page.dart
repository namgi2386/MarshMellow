import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; 

class FinanceAnalysisPage extends StatelessWidget {
  const FinanceAnalysisPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FinanceAnalysisPage page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('자산유형분석 '),
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