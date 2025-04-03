import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:marshmellow/presentation/widgets/custom_appbar/custom_appbar.dart';
import 'package:marshmellow/core/constants/icon_path.dart';
import 'package:marshmellow/presentation/widgets/modal/modal.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/presentation/pages/cookie/widgets/portfolio/portfolio_form.dart';


class PortfolioPage extends StatelessWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: '포트폴리오', actions: [
        IconButton(
          onPressed: () {
            // 추가 로직
            showCustomModal(
              context: context,
              backgroundColor: AppColors.background,
              child: const PortfolioForm(),
            );
          },
          icon: SvgPicture.asset(IconPath.add),
        ),
        IconButton(
          onPressed: () {
            // 공유 로직
          },
          icon: SvgPicture.asset(IconPath.shareNetwork),
        ),
      ]),
      body: Column(
        children: [
          Text('포트폴리오'),
        ],
      ),
    );
  }
}
