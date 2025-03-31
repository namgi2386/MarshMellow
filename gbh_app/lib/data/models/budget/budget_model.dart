/*
  전체 예산 조회 API 응답 모델
*/
import 'package:flutter/material.dart';
import 'package:marshmellow/core/theme/app_colors.dart';

class BudgetResponse {
  final int code;
  final String message;
  final BudgetData data;

  BudgetResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory BudgetResponse.fromJson(Map<String, dynamic> json) {
    return BudgetResponse(
      code: json['code'], 
      message: json['message'], 
      data: BudgetData.fromJson(json['data'])
    );
  }
}

class BudgetData {
  final String message;
  final List<Budget> budgetList;

  BudgetData({
    required this.message,
    required this.budgetList,
  });

  factory BudgetData.fromJson(Map<String, dynamic> json) {
    return BudgetData(
      message: json['message'], 
      budgetList: (json['budgetList'] as List)
          .map((item) => Budget.fromJson(item))
          .toList(),
    );
  }
}

class Budget {
  final int budgetPk;
  final int budgetAmount;
  final String startDate;
  final String endDate;
  final List<BudgetCategory> budgetCategoryList;

  Budget({
    required this.budgetPk,
    required this.budgetAmount,
    required this.startDate,
    required this.endDate,
    required this.budgetCategoryList,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      budgetPk: json['budgetPk'],
      budgetAmount: json['budgetAmount'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      budgetCategoryList: (json['budgetCategoryList'] as List)
          .map((item) => BudgetCategory.fromJson(item))
          .toList(),
    );
  }

  static Map<String, Color> getCategoryColors() {
    return {
      '식비': AppColors.yellowPrimary,
      '교통비' : AppColors.bluePrimary,
      '여가' : AppColors.greenLight,
      '커피/디저트' : AppColors.yellowLight,
      '쇼핑' : AppColors.pinkLight,
      '생활' : AppColors.pinkPrimary,
      '주거' : AppColors.blueLight,
      '의료' : AppColors.blueDark,
      '기타' : AppColors.whiteLight,
    };
  }

  // 카테고리별 색상 가져오기
  static Color getCategoryColor(String categoryName) {
    final colors = getCategoryColors();
    return colors[categoryName] ?? AppColors.background;
  }
}

class BudgetCategory {
  final int budgetCategoryPk;
  final String budgetCategoryName;
  final int budgetCategoryPrice;
  final int? budgetExpendAmount;
  final double? budgetExpendPercent;

  BudgetCategory({
    required this.budgetCategoryPk,
    required this.budgetCategoryName,
    required this.budgetCategoryPrice,
    this.budgetExpendAmount,
    this.budgetExpendPercent,
  });

  factory BudgetCategory.fromJson(Map<String, dynamic> json) {
    return BudgetCategory(
      budgetCategoryPk: json['budgetCategoryPk'], 
      budgetCategoryName: json['budgetCategoryName'], 
      budgetCategoryPrice: json['budgetCategoryPrice'],
      budgetExpendAmount: json['budgetExpendAmount'] != null 
          ? json['budgetExpendAmount']
          : 0,
      budgetExpendPercent: json['budgetExpendPercent'] != null
          ? json['budgetExpendPercent'].toDouble()
          : null,
    );
  }

  // 사용 비율 계산
  double get usageRatio {
    return budgetExpendPercent ?? 0.0;
  }

  // 예산 초과 여부
  bool get isOverBudget {
    return (budgetExpendPercent ?? 0.0) > 1.0;
  }

  // 색상 가져오기
  Color get color {
    return Budget.getCategoryColor(budgetCategoryName);
  }
}