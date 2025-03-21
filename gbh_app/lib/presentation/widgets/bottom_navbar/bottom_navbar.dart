import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';

/*
  하단 네비게이션바 UI
*/
class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;
  final List<String> iconPaths;
  final List<String> labels;

  const CustomBottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onTap,
    required this.iconPaths,
    required this.labels,
  }) : super(key: key);

  // 아이콘 경로 변환
  String getWhiteIconPath(String blackIconPath) {
    return blackIconPath.replaceAll('_bk.svg', '_wh.svg');
  }

  @override
  Widget build(BuildContext context) {
    return ConvexAppBar(
      style: TabStyle.reactCircle,
      // 네브바 배경색 지정
      backgroundColor: AppColors.backgroundBlack, 
      // 선택탭 튀어나온 부분 색상 지정
      gradient: LinearGradient( 
        colors: [AppColors.backgroundBlack, AppColors.backgroundBlack],
      ),
      // 그림자 제거
      shadowColor: Colors.transparent,
      activeColor: AppColors.whiteLight,
      height: 50,
      top: -20,
      items: _buildTabItems(),
      initialActiveIndex: selectedIndex,
      onTap: onTap,
      curve: Curves.easeInOut,
    );
  }

  List<TabItem> _buildTabItems() {
    return List.generate(
      iconPaths.length,
      (index) => TabItem(
        icon: SizedBox(
          width: 24,
          height: 24,
          child: SvgPicture.asset(
            selectedIndex == index ? iconPaths[index] : getWhiteIconPath(iconPaths[index]),
            // 아이콘 크기 조정 
            fit: BoxFit.scaleDown,
          ),
        ),
        title:labels[index],
        textStyle: AppTextStyles.bodyExtraSmall.copyWith(
          color: AppColors.whiteLight,
        ),
      ),
    );
  }
}