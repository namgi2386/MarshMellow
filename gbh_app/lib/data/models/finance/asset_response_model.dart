import 'package:marshmellow/data/models/finance/card_model.dart';
import 'package:marshmellow/data/models/finance/account_models.dart';

// 응답의 최상위 모델
class AssetResponseModel {
  final int code;
  final String message;
  final AssetData data;

  AssetResponseModel({
    required this.code,
    required this.message,
    required this.data,
  });

  factory AssetResponseModel.fromJson(Map<String, dynamic> json) {
    return AssetResponseModel(
      code: json['code'],
      message: json['message'],
      data: AssetData.fromJson(json['data']),
    );
  }
}

// 모든 자산 데이터를 포함하는 모델
class AssetData {
  final CardData cardData;
  final DemandDepositData demandDepositData;
  final LoanData loanData;
  final SavingsData savingsData;
  final DepositData depositData;

  AssetData({
    required this.cardData,
    required this.demandDepositData,
    required this.loanData,
    required this.savingsData,
    required this.depositData,
  });

  factory AssetData.fromJson(Map<String, dynamic> json) {
    return AssetData(
      cardData: CardData.fromJson(json['cardData']),
      demandDepositData: DemandDepositData.fromJson(json['demandDepositData']),
      loanData: LoanData.fromJson(json['loanData']),
      savingsData: SavingsData.fromJson(json['savingsData']),
      depositData: DepositData.fromJson(json['depositData']),
    );
  }
}