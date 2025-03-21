import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  // 아이콘 경로 흰색 아이콘 경로
  // 'assets/icons/nav/budget_bk.svg' -> 'assets/icons/nav/budget_wh.svg'
  String getWhiteIconPath(String blackIconPath) {
    return blackIconPath.replaceAll('_bk.svg', '_wh.svg');
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double navBarHeight = 70.0;

    return SizedBox(
      width: screenWidth,
      height: navBarHeight,
      child: Stack(
        clipBehavior: Clip.none, // 오버플로우 허용
        children: [
          // 커스텀 곡선형 배경
          Positioned.fill(
            child: CustomPaint(
              painter: NavBarPainter(
                selectedIndex: selectedIndex,
                itemCount: iconPaths.length,
              ),
            ),
          ),
          
          // 탭 아이템들
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(iconPaths.length, (index) {
              return _buildNavItem(index, navBarHeight);
            }),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNavItem(int index, double navBarHeight) {
    bool isSelected = selectedIndex == index;
    final double circleSize = 56.0;
    final double pushUpOffset = 15.0;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 70,
        height: navBarHeight,
        child: Stack(
          clipBehavior: Clip.none, // 오버플로우 허용
          alignment: Alignment.center,
          children: [
            // 선택된 탭 : 위로 올라가는 원 + 검은색 아이콘
            if (isSelected)
              Positioned(
                top: navBarHeight / 2 - circleSize / 2 - pushUpOffset,
                child: Container(
                  width: circleSize,
                  height: circleSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.background,
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: Colors.black.withOpacity(0.1),
                    //     blurRadius: 4,
                    //     offset: Offset(0, 2),
                    //   ),
                    // ],
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      iconPaths[index], // 검은색 아이콘 사용
                      width: 28,
                      height: 28,
                    ),
                  ),
                ),
              ),
              
            // 선택되지 않은 경우의 흰색 아이콘 + 라벨
            if (!isSelected)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    getWhiteIconPath(iconPaths[index]), // 흰색 아이콘 사용
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    labels[index],
                    style: AppTextStyles.bodyExtraSmall.copyWith(
                      color: AppColors.whiteLight.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// 곡선형 네비게이션바를 그리자 CustomPainter
class NavBarPainter extends CustomPainter {
  final int selectedIndex;
  final int itemCount;
  
  NavBarPainter({
    required this.selectedIndex,
    required this.itemCount,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;
    final double itemWidth = width / itemCount;
    
    // 선택된 탭의 중앙 위치
    final double selectedItemCenter = itemWidth * (selectedIndex + 0.5);
    
    // 곡선의 중앙이 올라가는 높이
    final double curveHeight = 15.0;
    
    // 곡선의 너비
    final double curveWidth = 75.0;
    
    // 배경 색상
    final paint = Paint()..color = AppColors.backgroundBlack;
    
    // 전체 배경을 먼저 그림 (직사각형)
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paint);
    
    // 곡선 부분을 지우기 위한 Path 생성
    final cuttingPath = Path();
    
    // 곡선 시작
    cuttingPath.moveTo(selectedItemCenter - curveWidth / 2, 0);
    
    // 위로 올라가는 곡선 (원형과 유사하게)
    cuttingPath.cubicTo(
      selectedItemCenter - curveWidth / 3, 0,
      selectedItemCenter - curveWidth / 4, -curveHeight,
      selectedItemCenter, -curveHeight
    );
    
    // 내려오는 곡선
    cuttingPath.cubicTo(
      selectedItemCenter + curveWidth / 4, -curveHeight,
      selectedItemCenter + curveWidth / 3, 0,
      selectedItemCenter + curveWidth / 2, 0
    );
    
    // 지우기 모드로 그리기
    canvas.drawPath(cuttingPath, Paint()
      ..color = Colors.transparent
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.fill);
  }
  
  @override
  bool shouldRepaint(covariant NavBarPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex;
  }
}