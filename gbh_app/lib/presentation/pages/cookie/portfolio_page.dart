import 'package:flutter/material.dart';
import 'package:marshmellow/presentation/widgets/custom_appbar/custom_appbar.dart';

class PortfolioPage extends StatelessWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: '포트폴리오'),
      body: Column(
        children: [
          Text('포트폴리오'),
        ],
      ),
    );
  }
}
