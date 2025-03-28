import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:graphic/graphic.dart';

import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';

class ChartData {
  final String title;
  final double value;
  final Color color;

  ChartData({required this.title, required this.value, required this.color});
}

class DoughnutChart extends StatefulWidget {
  final List<ChartData> data;

  const DoughnutChart({super.key, required this.data});

  @override
  State<DoughnutChart> createState() => _DoughnutChartState();
}

class _DoughnutChartState extends State<DoughnutChart>
    with SingleTickerProviderStateMixin {
  int? touchedIndex;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // 애니메이션 속도 줄이기
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut, // 좀 더 자연스러운 애니메이션
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value > 0.1 ? 1.0 : 0.0, // 초반 깜빡임 방지
          child: PieChart(
            PieChartData(
              sectionsSpace: 2, // 구분선 추가
              centerSpaceRadius: 50, // 도넛 스타일
              sections: _generateSections(_animation.value),
              borderData: FlBorderData(show: false),
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
            ),
          ),
        );
      },
    );
  }

  List<PieChartSectionData> _generateSections(double animationValue) {
    return widget.data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final baseRadius = 80.0;
      final isTouched = touchedIndex == index;
      final radius = isTouched ? baseRadius * 1.2 : baseRadius;
      final animatedValue = item.value * animationValue;
      final showTitle = animationValue > 0.8;
      final fontSize = isTouched ? 16.0 : 12.0;
      final fontWeight = isTouched ? FontWeight.bold : FontWeight.normal;

      return PieChartSectionData(
        color: item.color,
        value: animatedValue,
        title: showTitle ? '${item.title}\n${(animatedValue).toInt()}%' : '',
        radius: radius,
        titleStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.greyDark,
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      );
    }).toList();
  }
}
