import 'package:flutter/material.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/core/constants/icon_path.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:marshmellow/presentation/widgets/custom_appbar/custom_appbar.dart';
import 'package:marshmellow/presentation/pages/ledger/widgets/chart/doughnut_chart.dart'
    as doughnut;
import 'package:marshmellow/presentation/pages/ledger/widgets/chart/column_chart.dart'
    as column;

class LedgerAnalysisPage extends StatelessWidget {
  const LedgerAnalysisPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth * 0.9;
    final screenHeight = MediaQuery.of(context).size.height;

    // 도넛 차트 데이터
    final chartData = [
      doughnut.ChartData(
          title: '식비', value: 35, color: AppColors.yellowPrimary),
      doughnut.ChartData(title: '교통비', value: 25, color: AppColors.pinkPrimary),
      doughnut.ChartData(title: '쇼핑', value: 20, color: AppColors.bluePrimary),
      doughnut.ChartData(title: '문화', value: 10, color: AppColors.greenPrimary),
      doughnut.ChartData(title: '의료', value: 7, color: AppColors.whiteLight),
      doughnut.ChartData(title: '기타', value: 3, color: AppColors.blackPrimary),
    ];

    // 컬럼 차트 데이터
    final columnChartData = [
      column.ChartData(
          label: '3월 1주', value: 400000, color: AppColors.pinkPrimary),
      column.ChartData(
          label: '3월 2주', value: 500000, color: AppColors.pinkPrimary),
      column.ChartData(
          label: '3월 3주', value: 200000, color: AppColors.pinkPrimary),
      column.ChartData(
          label: '3월 4주', value: 400000, color: AppColors.pinkPrimary),
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

                  // 섹션 제목
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
                    child: Text(
                      '카테고리별 지출',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),

                  // 도넛 차트 컨테이너
                  SizedBox(
                    height: screenHeight * 0.35, // 화면 높이에 맞게 조정
                    child: doughnut.DoughnutChart(data: chartData),
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

                  const SizedBox(height: 24),

                  // 주차별 지출 섹션 제목
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                    child: Text(
                      '주차별 지출',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),

                  // 컬럼 차트 컨테이너
                  SizedBox(
                    height: screenHeight * 0.3,
                    child: column.ColumnChart(data: columnChartData),
                  ),

                  // 여백을 위한 공간
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
