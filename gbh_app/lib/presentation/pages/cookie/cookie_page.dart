import 'package:flutter/material.dart';

// 테마
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/core/theme/app_colors.dart';

// 라우트
import 'package:marshmellow/router/routes/cookie_routes.dart';

// 위젯
import 'package:marshmellow/presentation/widgets/custom_appbar/custom_appbar.dart';
import 'package:marshmellow/presentation/pages/cookie/widgets/cards/lunch_card.dart';
import 'package:marshmellow/presentation/pages/cookie/widgets/cards/quit_card.dart';
import 'package:marshmellow/presentation/pages/cookie/widgets/cards/portfolio_card.dart';

class CookiePage extends StatelessWidget {
  const CookiePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth * 0.9;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: const CustomAppbar(
        title: '내가 만든 쿠키🍪',
      ),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: contentWidth,
            child: Column(
              children: [
                // 점심 메뉴 추천 카드
                Padding(
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                  child: const LunchCard(),
                ),

                // 퇴사 망상 카드
                Padding(
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                  child: const QuitCard(),
                ),

                // 포트폴리오 카드
                Padding(
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                  child: const PortfolioCard(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
