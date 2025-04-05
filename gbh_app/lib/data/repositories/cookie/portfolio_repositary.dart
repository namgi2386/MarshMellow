import 'dart:io';
import 'package:marshmellow/data/datasources/remote/portfolio_api.dart';
import 'package:marshmellow/data/models/cookie/portfolio/portfolio_model.dart';
import 'package:marshmellow/data/models/cookie/portfolio/portfolio_category_model.dart';

class PortfolioRepository {
  final PortfolioApi _portfolioApi;

  PortfolioRepository(this._portfolioApi);

  // 포트폴리오 등록
  Future<Portfolio> createPortfolio({
    required File file,
    required String portfolioMemo,
    required String fileName,
    required int portfolioCategoryPk,
  }) async {
    return await _portfolioApi.createPortfolio(
      file: file,
      portfolioMemo: portfolioMemo,
      fileName: fileName,
      portfolioCategoryPk: portfolioCategoryPk,
    );
  }

  // 포트폴리오 카테고리 목록 조회
  Future<List<PortfolioCategory>> getPortfolioCategories() async {
    return await _portfolioApi.getPortfolioCategories();
  }

  // 포트폴리오 카테고리 등록
  Future<List<PortfolioCategory>> createPortfolioCategory({
    required String categoryMemo,
    required String categoryName,
  }) async {
    return await _portfolioApi.createPortfolioCategory(
      categoryMemo: categoryMemo,
      categoryName: categoryName,
    );
  }

// 포트폴리오 카테고리 수정
  Future<PortfolioCategory> updatePortfolioCategory({
    required int categoryPk,
    String? categoryName,
    String? categoryMemo,
  }) async {
    return await _portfolioApi.updatePortfolioCategory(
      categoryPk: categoryPk,
      categoryName: categoryName,
      categoryMemo: categoryMemo,
    );
  }

// 포트폴리오 카테고리 삭제
  Future<bool> deletePortfolioCategory({
    required int categoryPk,
  }) async {
    return await _portfolioApi.deletePortfolioCategory(
      categoryPk: categoryPk,
    );
  }

// 포트폴리오 목록 조회
  Future<List<Portfolio>> getPortfolioList() async {
    return await _portfolioApi.getPortfolioList();
  }

// 포트폴리오 상세 조회
  Future<Portfolio> getPortfolioDetail({
    required int portfolioPk,
  }) async {
    return await _portfolioApi.getPortfolioDetail(
      portfolioPk: portfolioPk,
    );
  }

// 포트폴리오 수정
  Future<Portfolio> updatePortfolio({
    required int portfolioPk,
    required int portfolioCategoryPk,
    File? file,
    String? portfolioMemo,
    String? fileName,
  }) async {
    return await _portfolioApi.updatePortfolio(
      portfolioPk: portfolioPk,
      portfolioCategoryPk: portfolioCategoryPk,
      file: file,
      portfolioMemo: portfolioMemo,
      fileName: fileName,
    );
  }

// 포트폴리오 삭제
  Future<bool> deletePortfolio({
    required int portfolioPk,
  }) async {
    return await _portfolioApi.deletePortfolio(
      portfolioPk: portfolioPk,
    );
  }
}
