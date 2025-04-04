import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marshmellow/data/datasources/remote/portfolio_api.dart';
import 'package:marshmellow/data/repositories/cookie/portfolio_repositary.dart';
import 'package:marshmellow/di/providers/api_providers.dart';
import 'package:marshmellow/presentation/viewmodels/portfolio/portfolio_veiwmodel.dart';
import 'package:marshmellow/data/models/cookie/portfolio/portfolio_model.dart';

// API 프로바이더
final portfolioApiProvider = Provider<PortfolioApi>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PortfolioApi(apiClient);
});

// 저장소 프로바이더
final portfolioRepositoryProvider = Provider<PortfolioRepository>((ref) {
  final portfolioApi = ref.watch(portfolioApiProvider);
  return PortfolioRepository(portfolioApi);
});

// 카테고리별 포트폴리오 필터링 프로바이더
final portfoliosByCategoryProvider = Provider.family<List<Portfolio>, int>((ref, categoryPk) {
  final portfolios = ref.watch(portfolioViewModelProvider).portfolios;
  if (categoryPk == 0) return portfolios; // 0은 모든 카테고리를 의미한다고 가정
  return portfolios.where((p) => p.portfolioCategoryPk == categoryPk).toList();
});

// 특정 포트폴리오 상세 정보 프로바이더
final portfolioDetailProvider = FutureProvider.family<Portfolio?, int>((ref, portfolioPk) async {
  return ref.watch(portfolioViewModelProvider.notifier).getPortfolioDetail(portfolioPk);
});