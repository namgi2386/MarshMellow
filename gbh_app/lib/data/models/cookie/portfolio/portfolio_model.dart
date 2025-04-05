import 'package:marshmellow/data/models/cookie/portfolio/portfolio_category_model.dart';

class Portfolio {
  final int? portfolioPk;
  final String? fileUrl;
  final String? createDate;
  final String? createTime;
  final String originFileName;
  final String fileName;
  final String portfolioMemo;
  final PortfolioCategory? portfolioCategory;
  final int portfolioCategoryPk;

  Portfolio({
    this.portfolioPk,
    this.fileUrl,
    this.createDate,
    this.createTime,
    required this.originFileName,
    required this.fileName,
    required this.portfolioMemo,
    this.portfolioCategory,
    required this.portfolioCategoryPk,
  });

  factory Portfolio.fromJson(Map<String, dynamic> json) {
    return Portfolio(
      portfolioPk: json['portfolioPk'] as int?,
      fileUrl: json['fileUrl'] as String?,
      createDate: json['createDate'] as String?,
      createTime: json['createTime'] as String?,
      originFileName: json['originFileName'] as String,
      fileName: json['fileName'] as String,
      portfolioMemo: json['portfolioMemo'] as String,
      portfolioCategory: json['portfolioCategory'] != null
          ? PortfolioCategory.fromJson(json['portfolioCategory'])
          : null,
      portfolioCategoryPk: json['portfolioCategory'] != null
          ? json['portfolioCategory']['portfolioCategoryPk']
          : json['portfolioCategoryPk'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'portfolioMemo': portfolioMemo,
      'portfolioCategoryPk': portfolioCategoryPk,
    };
  }
}


// 포트폴리오 목록
class PortfolioListResponse {
  final int code;
  final String message;
  final PortfolioListData data;

  PortfolioListResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory PortfolioListResponse.fromJson(Map<String, dynamic> json) {
    return PortfolioListResponse(
      code: json['code'] as int,
      message: json['message'] as String,
      data: PortfolioListData.fromJson(json['data']),
    );
  }
}

class PortfolioListData {
  final List<Portfolio> portfolioList;

  PortfolioListData({
    required this.portfolioList,
  });

  factory PortfolioListData.fromJson(Map<String, dynamic> json) {
    final List<dynamic> portfolioJson = json['portfolioList'] as List;
    final portfolios = portfolioJson
        .map((item) => Portfolio.fromJson(item as Map<String, dynamic>))
        .toList();
    return PortfolioListData(portfolioList: portfolios);
  }
}
