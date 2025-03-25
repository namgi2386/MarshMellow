import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marshmellow/data/datasources/remote/finance_api.dart';
import 'package:marshmellow/data/models/finance/asset_response_model.dart';

// 자산 데이터를 가져오는 뷰모델 프로바이더
final financeViewModelProvider = Provider((ref) {
  return FinanceViewModel(ref);
});

// 자산 데이터 상태 프로바이더
final assetDataProvider = FutureProvider<AssetResponseModel>((ref) async {
  final viewModel = ref.watch(financeViewModelProvider);
  return await viewModel.getAssetInfo();
});

class FinanceViewModel {
  final ProviderRef _ref;
  
  FinanceViewModel(this._ref);
  
  // API를 통해 자산 정보 가져오기
  Future<AssetResponseModel> getAssetInfo() async {
    final financeApi = _ref.read(financeApiProvider);
    // 테스트용 고정 userKey 사용
    return await financeApi.getAssetInfo("2c2fd595-4118-4b6c-9fd7-fc811910bb75");
  }
  
  // 총 자산 계산 메소드
  int calculateTotalAssets(AssetData assetData) {
    return assetData.cardData.totalAmount + 
          assetData.demandDepositData.totalAmount + 
          assetData.savingsData.totalAmount + 
          assetData.depositData.totalAmount - 
          assetData.loanData.totalAmount;
  }
}