import 'package:flutter/material.dart';

// 위젯
import 'package:marshmellow/presentation/widgets/custom_appbar/custom_appbar.dart';

class LunchPage extends StatelessWidget {
  const LunchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: '점심 메뉴 추천'),
      body: Column(
        children: [
          Text('점심 메뉴 추천'),
        ],
      ),
    );
  }
}

