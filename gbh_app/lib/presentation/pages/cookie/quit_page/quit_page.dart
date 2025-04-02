import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:marshmellow/core/constants/icon_path.dart';

// 라우트
import 'package:go_router/go_router.dart';
import 'package:marshmellow/router/routes/cookie_routes.dart';

// 위젯
import 'package:marshmellow/presentation/widgets/custom_appbar/custom_appbar.dart';
import 'package:marshmellow/presentation/widgets/celebration/celebration.dart';

class QuitPage extends StatefulWidget {
  const QuitPage({super.key});

  @override
  State<QuitPage> createState() => _QuitPageState();
}

class _QuitPageState extends State<QuitPage> {
  @override
  void initState() {
    super.initState();

    // 화면이 완전히 빌드된 후 컨페티 효과 표시 (빌드 직후 팝업을 표시하기 위한 방법)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showRetirementCelebration(context);
    });
  }

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
