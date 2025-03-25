import 'package:flutter/material.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/core/constants/icon_path.dart';
import 'package:marshmellow/presentation/widgets/custom_appbar/custom_appbar.dart';

class LedgerSearchPage extends StatelessWidget {
  const LedgerSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: '검색'),
      body: SafeArea(
        child: Column(
          children: [
            Text('검색'),
          ],
        ),
      ),
    );
  }
}