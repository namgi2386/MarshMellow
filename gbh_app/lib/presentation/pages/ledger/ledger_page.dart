import 'package:flutter/material.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/presentation/widgets/custom_appbar/custom_appbar.dart';
import 'package:marshmellow/core/utils/icon_path.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LedgerPage extends StatelessWidget {
  const LedgerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: '가계부', actions: [
        IconButton(
          icon: SvgPicture.asset(IconPath.analysis),
          onPressed: () {},
        )
      ]),
      body: Center(
        child: Text('가계부'),
      ),
    );
  }
}
