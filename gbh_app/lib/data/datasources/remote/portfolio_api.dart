import 'dart:io';
import 'package:dio/dio.dart';
import 'package:marshmellow/data/datasources/remote/api_client.dart';
import 'package:marshmellow/data/models/cookie/portfolio/portfolio_model.dart';
import 'package:marshmellow/data/models/cookie/portfolio/portfolio_category_model.dart';

class PortfolioApi {
  final ApiClient _apiClient;

  PortfolioApi(this._apiClient);

  // 포트폴리오 등록
  Future<Portfolio> createPortfolio({
    required File file,
    required String portfolioMemo,
    required String fileName,
    required int portfolioCategoryPk,
  }) async {
    // FormData 생성
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
      'portfolioMemo': portfolioMemo,
      'fileName': fileName,
      'portfolioCategoryPk': portfolioCategoryPk,
    });

    final response = await _apiClient.post(
      '/portfolio',
      data: formData,
    );

    if (response.data['code'] == 200 && response.data['data'] != null) {
      return Portfolio.fromJson(response.data['data']);
    } else {
      throw Exception('포트폴리오 등록 실패: ${response.data['message']}');
    }
  }

  // 포트폴리오 목록 조회
  Future<List<Portfolio>> getPortfolioList() async {
    final response = await _apiClient.get('/portfolio/list');

    if (response.data['code'] == 200 && response.data['data'] != null) {
      final data = response.data['data'];
      List<dynamic> portfolioJson = data['portfolioList'];
      return portfolioJson.map((json) => Portfolio.fromJson(json)).toList();
    } else {
      throw Exception('포트폴리오 목록 조회 실패: ${response.data['message']}');
    }
  }

  // 포트폴리오 카테고리 목록 조회
  Future<List<PortfolioCategory>> getPortfolioCategories() async {
    final response = await _apiClient.get('/portfolio/category');

    List<dynamic> categoriesJson =
        response.data['data']['portfolioCategoryList'];
    return categoriesJson
        .map((json) => PortfolioCategory.fromJson(json))
        .toList();
  }

  // 포트폴리오 카테고리 등록
  Future<List<PortfolioCategory>> createPortfolioCategory({
    required String categoryMemo,
    required String categoryName,
  }) async {
    final data = {
      'categoryMemo': categoryMemo,
      'categoryName': categoryName,
    };

    final response = await _apiClient.post(
      '/portfolio/category',
      data: data,
    );

    if (response.data['code'] == 200 && response.data['data'] != null) {
      List<dynamic> categoriesJson =
          response.data['data']['portfolioCategoryList'];
      return categoriesJson
          .map((json) => PortfolioCategory.fromJson(json))
          .toList();
    } else {
      throw Exception('포트폴리오 카테고리 등록 실패: ${response.data['message']}');
    }
  }

  // 포트폴리오 카테고리 목록 조회
  Future<List<PortfolioCategory>> getPortfolioCategoryList() async {
    final response = await _apiClient.get('/portfolio/category-list');

    if (response.data['code'] == 200 && response.data['data'] != null) {
      List<dynamic> categoriesJson =
          response.data['data']['portfolioCategoryList'];
      return categoriesJson
          .map((json) => PortfolioCategory.fromJson(json))
          .toList();
    } else {
      throw Exception('포트폴리오 카테고리 목록 조회 실패: ${response.data['message']}');
    }
  }

  // 포트폴리오 카테고리 수정
  Future<PortfolioCategory> updatePortfolioCategory({
    required int categoryPk,
    String? categoryName,
    String? categoryMemo,
  }) async {
    final Map<String, dynamic> data = {
      'categoryPk': categoryPk,
    };

    if (categoryName != null) {
      data['categoryName'] = categoryName;
    }

    if (categoryMemo != null) {
      data['categoryMemo'] = categoryMemo;
    }

    final response = await _apiClient.patch(
      '/portfolio/category',
      data: data,
    );

    if (response.data['code'] == 200 && response.data['data'] != null) {
      return PortfolioCategory.fromJson(response.data['data']);
    } else {
      throw Exception('포트폴리오 카테고리 수정 실패: ${response.data['message']}');
    }
  }

  // 포트폴리오 카테고리 삭제
  Future<bool> deletePortfolioCategory({
    required int categoryPk,
  }) async {
    final data = {
      'categoryPk': categoryPk,
    };

    final response = await _apiClient.delete(
      '/portfolio/category',
      data: data,
    );

    if (response.data['code'] == 200 &&
        response.data['data'] != null &&
        response.data['data']['message'] == 'SUCCESS') {
      return true;
    } else {
      throw Exception('포트폴리오 카테고리 삭제 실패: ${response.data['message']}');
    }
  }

  // 포트폴리오 상세 조회
  Future<Portfolio> getPortfolioDetail({
    required int portfolioPk,
  }) async {
    final data = {
      'portfolioPk': portfolioPk,
    };

    final response = await _apiClient.get(
      '/portfolio',
      queryParameters: data,
    );

    if (response.data['code'] == 200 && response.data['data'] != null) {
      return Portfolio.fromJson(response.data['data']);
    } else {
      throw Exception('포트폴리오 상세 조회 실패: ${response.data['message']}');
    }
  }

  // 포트폴리오 수정
  Future<Portfolio> updatePortfolio({
    required int portfolioPk,
    required int portfolioCategoryPk,
    File? file,
    String? portfolioMemo,
    String? fileName,
  }) async {
    // FormData 생성
    final formData = FormData.fromMap({
      'portfolioPk': portfolioPk,
      'portfolioCategoryPk': portfolioCategoryPk,
    });

    // Optional parameters
    if (file != null) {
      formData.files.add(MapEntry(
        'file',
        await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      ));
    }

    if (portfolioMemo != null) {
      formData.fields.add(MapEntry('portfolioMemo', portfolioMemo));
    }

    if (fileName != null) {
      formData.fields.add(MapEntry('fileName', fileName));
    }

    final response = await _apiClient.patch(
      '/portfolio',
      data: formData,
    );

    if (response.data['code'] == 200 && response.data['data'] != null) {
      return Portfolio.fromJson(response.data['data']);
    } else {
      throw Exception('포트폴리오 수정 실패: ${response.data['message']}');
    }
  }

  // 포트폴리오 삭제
  Future<bool> deletePortfolio({
    required int portfolioPk,
  }) async {
    final data = {
      'portfolioPk': portfolioPk,
    };

    final response = await _apiClient.delete(
      '/portfolio',
      data: data,
    );

    if (response.data['code'] == 200 &&
        response.data['data'] != null &&
        response.data['data']['message'] == 'SUCCESS') {
      return true;
    } else {
      throw Exception('포트폴리오 삭제 실패: ${response.data['message']}');
    }
  }
}
