import 'package:flutter/material.dart';
import 'package:marshmellow/presentation/widgets/custom_appbar/custom_appbar.dart';


class LunchTutorialPage extends StatelessWidget {
  const LunchTutorialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: '튜토리얼'),
      body: Column(
        children: [
          Text('튜토리얼'),
        ],
      ),
    );
  }
}

