class PortfolioCategory {
  final int portfolioCategoryPk;
  final String portfolioCategoryName;
  final String portfolioCategoryMemo;

  PortfolioCategory({
    required this.portfolioCategoryPk,
    required this.portfolioCategoryName,
    required this.portfolioCategoryMemo,
  });

  factory PortfolioCategory.fromJson(Map<String, dynamic> json) {
    return PortfolioCategory(
      portfolioCategoryPk: json['portfolioCategoryPk'] as int,
      portfolioCategoryName: json['portfolioCategoryName'] as String,
      portfolioCategoryMemo: json['portfolioCategoryMemo'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'portfolioCategoryPk': portfolioCategoryPk,
      'portfolioCategoryName': portfolioCategoryName,
      'portfolioCategoryMemo': portfolioCategoryMemo,
    };
  }
}

// 포트폴리오 카테고리 목록 응답 클래스
class PortfolioCategoryListResponse {
  final int code;
  final String message;
  final PortfolioCategoryListData data;

  PortfolioCategoryListResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory PortfolioCategoryListResponse.fromJson(Map<String, dynamic> json) {
    return PortfolioCategoryListResponse(
      code: json['code'] as int,
      message: json['message'] as String,
      data: PortfolioCategoryListData.fromJson(json['data']),
    );
  }
}

class PortfolioCategoryListData {
  final List<PortfolioCategory> portfolioCategoryList;

  PortfolioCategoryListData({
    required this.portfolioCategoryList,
  });

  factory PortfolioCategoryListData.fromJson(Map<String, dynamic> json) {
    final List<dynamic> categoryJson = json['portfolioCategoryList'] as List;
    final categories = categoryJson
        .map((item) => PortfolioCategory.fromJson(item as Map<String, dynamic>))
        .toList();
    return PortfolioCategoryListData(portfolioCategoryList: categories);
  }
}