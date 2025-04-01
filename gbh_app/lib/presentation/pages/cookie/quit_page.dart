import 'package:flutter/material.dart';

// 위젯
import 'package:marshmellow/presentation/widgets/custom_appbar/custom_appbar.dart';

class QuitPage extends StatelessWidget {
  const QuitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: '퇴사 망상'),
      body: Column(
        children: [
          Text('퇴사 망상'),
        ],
      ),
    );
  }
}
