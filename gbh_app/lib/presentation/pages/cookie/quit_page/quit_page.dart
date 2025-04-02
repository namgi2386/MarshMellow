import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:marshmellow/core/constants/icon_path.dart';

// 라우트
import 'package:go_router/go_router.dart';
import 'package:marshmellow/router/routes/cookie_routes.dart';

// 위젯
import 'package:marshmellow/presentation/widgets/custom_appbar/custom_appbar.dart';

class QuitPage extends StatelessWidget {
  const QuitPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: '퇴사 망상',
        actions: [
          IconButton(
            onPressed: () => context.push(CookieRoutes.getQuitInfoPath()),
            icon: SvgPicture.asset(IconPath.question),
          ),
        ],
      ),
      body: Column(
        children: [
          Text('내용입니다'),
        ],
      ),
    );
  }
}
