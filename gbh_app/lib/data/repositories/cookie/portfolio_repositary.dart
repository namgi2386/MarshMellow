import 'dart:io';
import 'package:marshmellow/data/datasources/remote/portfolio_api.dart';
import 'package:marshmellow/data/models/cookie/portfolio/portfolio_model.dart';
import 'package:marshmellow/data/models/cookie/portfolio/portfolio_category_model.dart';

class PortfolioRepository {
  final PortfolioApi _portfolioApi;

  PortfolioRepository(this._portfolioApi);

  // 포트폴리오 목록 조회
  Future<List<PortfolioModel>> getPortfolioList() async {
    try {
      final response = await _portfolioApi.getPortfolioList();

      if (response['code'] == 200 && response['data'] != null) {
        final data = response['data'];
        final portfolioListData = (data['portfolioList'] as List)
            .map((item) => PortfolioModel.fromJson(item))
            .toList();

        return portfolioListData;
      }

      throw Exception('API 응답 에러: ${response['message']}');
    } catch (e) {
      throw Exception('포트폴리오 목록을 가져오는데 실패했습니다: $e');
    }
  }

  // 포트폴리오 카테고리 목록 조회
  Future<List<PortfolioCategoryModel>> getPortfolioCategoryList() async {
    try {
      final response = await _portfolioApi.getPortfolioCategoryList();

      if (response['code'] == 200 && response['data'] != null) {
        final data = response['data'];
        final categoryListData = (data['portfolioCategoryList'] as List)
            .map((item) => PortfolioCategoryModel.fromJson(item))
            .toList();

        return categoryListData;
      }

      throw Exception('API 응답 에러: ${response['message']}');
    } catch (e) {
      throw Exception('포트폴리오 카테고리 목록을 가져오는데 실패했습니다: $e');
    }
  }

  // 포트폴리오를 카테고리별로 그룹화
  Map<PortfolioCategoryModel, List<PortfolioModel>> groupPortfoliosByCategory(
      List<PortfolioModel> portfolios) {
    final result = <PortfolioCategoryModel, List<PortfolioModel>>{};

    for (var portfolio in portfolios) {
      final category = portfolio.portfolioCategory;

      if (!result.containsKey(category)) {
        result[category] = [];
      }

      result[category]!.add(portfolio);
    }

    return result;
  }

  // 포트폴리오 등록
  Future<PortfolioModel> createPortfolio({
    required dynamic file,
    required String portfolioMemo,
    required String fileName,
    required int portfolioCategoryPk,
  }) async {
    try {
      final response = await _portfolioApi.createPortfolio(
        file: file,
        portfolioMemo: portfolioMemo,
        fileName: fileName,
        portfolioCategoryPk: portfolioCategoryPk,
      );

      if (response['code'] == 200 && response['data'] != null) {
        return PortfolioModel.fromJson(response['data']);
      }

      throw Exception('API 응답 에러: ${response['message']}');
    } catch (e) {
      throw Exception('포트폴리오 등록에 실패했습니다: $e');
    }
  }

// 포트폴리오 수정
  Future<PortfolioModel> updatePortfolio({
    required int portfolioPk,
    File? file,
    String? portfolioMemo,
    String? fileName,
    required int portfolioCategoryPk,
  }) async {
    try {
      final response = await _portfolioApi.updatePortfolio(
        portfolioPk: portfolioPk,
        file: file,
        portfolioMemo: portfolioMemo,
        fileName: fileName,
        portfolioCategoryPk: portfolioCategoryPk,
      );

      print('Repository received response: $response');

      if (response['code'] == 200 && response['data'] != null) {
        return PortfolioModel.fromJson(response['data']);
      }

      final message = response['message'] != null &&
              response['message'].toString().isNotEmpty
          ? response['message']
          : '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';

      throw Exception('API 응답 에러: $message');
    } catch (e) {
      print('Repository update error: $e');
      throw Exception('포트폴리오 수정에 실패했습니다: $e');
    }
  }

// 포트폴리오 카테고리 등록
  Future<List<PortfolioCategoryModel>> createPortfolioCategory({
    required String categoryName,
    required String categoryMemo,
  }) async {
    try {
      final response = await _portfolioApi.createPortfolioCategory(
        categoryName: categoryName,
        categoryMemo: categoryMemo,
      );

      if (response['code'] == 200 && response['data'] != null) {
        final data = response['data'];
        final categoryListData = (data['portfolioCategoryList'] as List)
            .map((item) => PortfolioCategoryModel.fromJson(item))
            .toList();

        return categoryListData;
      }

      throw Exception('API 응답 에러: ${response['message']}');
    } catch (e) {
      throw Exception('포트폴리오 카테고리 등록에 실패했습니다: $e');
    }
  }

  // 포트폴리오 카테고리 삭제
Future<bool> deletePortfolioCategories({
  required List<int> portfolioCategoryPkList,
}) async {
  try {
    final response = await _portfolioApi.deletePortfolioCategories(
      portfolioCategoryPkList: portfolioCategoryPkList,
    );

    if (response['code'] == 200 && response['data']['message'] == 'SUCCESS') {
      return true;
    }

    throw Exception('카테고리 삭제 실패: ${response['message']}');
  } catch (e) {
    throw Exception('포트폴리오 카테고리 삭제에 실패했습니다: $e');
  }
}

// 포트폴리오 목록 삭제
Future<bool> deletePortfolios({
  required List<int> portfolioPkList,
}) async {
  try {
    final response = await _portfolioApi.deletePortfolios(
      portfolioPkList: portfolioPkList,
    );

    if (response['code'] == 200 && response['data']['message'] == 'SUCCESS') {
      return true;
    }

    throw Exception('포트폴리오 삭제 실패: ${response['message']}');
  } catch (e) {
    throw Exception('포트폴리오 목록 삭제에 실패했습니다: $e');
  }
}
}
