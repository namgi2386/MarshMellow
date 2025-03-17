// lib/presentation/pages/testpage/counter_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../di/providers/test/counter_provider.dart';

class CounterPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 상태 읽기 - 값이 변경되면 위젯이 자동으로 다시 빌드됨
    final count = ref.watch(counterProvider);

    return Scaffold(
      appBar: AppBar(title: Text('카운터 예제')),
      body: Center(
        child: Text(
          '$count',
          style: TextStyle(fontSize: 48),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // 상태 변경하기
        onPressed: () => ref.read(counterProvider.notifier).state++,
        child: Icon(Icons.add),
      ),
    );
  }
}
