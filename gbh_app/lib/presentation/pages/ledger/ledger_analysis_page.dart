import 'package:flutter/material.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/core/constants/icon_path.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:marshmellow/presentation/widgets/custom_appbar/custom_appbar.dart';
import 'package:marshmellow/presentation/pages/ledger/widgets/chart/doughnut_chart.dart';

class LedgerAnalysisPage extends StatelessWidget {
  const LedgerAnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth * 0.9;
    final screenHeight = MediaQuery.of(context).size.height;

    // 도넛 차트 데이터
    final chartData = [
      ChartData(title: '식비', value: 35, color: AppColors.yellowPrimary),
      ChartData(title: '교통비', value: 25, color: AppColors.pinkPrimary),
      ChartData(title: '쇼핑', value: 20, color: AppColors.bluePrimary),
      ChartData(title: '문화', value: 10, color: AppColors.greenPrimary),
      ChartData(title: '의료', value: 7, color: AppColors.whiteLight),
      ChartData(title: '기타', value: 3, color: AppColors.blackPrimary),
    ];

    return Scaffold(
      appBar: CustomAppbar(title: '지출 분석'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: SizedBox(
              width: contentWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 날짜 선택 컨테이너
                  SizedBox(
                    height: 50,
                    width: screenWidth * 0.52,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SvgPicture.asset(IconPath.caretLeft),
                        Text(
                          '25.03.15 - 25.12.14',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SvgPicture.asset(IconPath.caretRight),
                      ],
                    ),
                  ),

                  // 차트 컨테이너
                  SizedBox(
                    height: screenHeight * 0.4, // 화면 높이에 맞게 조정
                    child: DoughnutChart(data: chartData),
                  ),

                  // 카테고리별 범례 (ListView.builder() 사용)
                  SizedBox(
                    height: chartData.length * 40, // 항목 개수에 따라 동적 높이 설정
                    child: ListView.builder(
                      shrinkWrap: true, // 부모 위젯의 크기를 초과하지 않도록 설정
                      physics: const NeverScrollableScrollPhysics(), // 스크롤 방지
                      itemCount: chartData.length,
                      itemBuilder: (context, index) {
                        final item = chartData[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: item.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                item.title,
                                style: AppTextStyles.moneyGraphMedium,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '${item.value.toInt()}%',
                                style: AppTextStyles.moneyGraphMedium.copyWith(
                                  color: AppColors.greyPrimary,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
