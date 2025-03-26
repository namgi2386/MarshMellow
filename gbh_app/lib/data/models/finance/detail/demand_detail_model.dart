// lib/data/models/finance/detail/demand_detail_model.dart

class DemandDetailResponse {
  final int code;
  final String message;
  final DemandDetailData data;

  DemandDetailResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory DemandDetailResponse.fromJson(Map<String, dynamic> json) {
    return DemandDetailResponse(
      code: json['code'],
      message: json['message'],
      data: DemandDetailData.fromJson(json['data']),
    );
  }
}

class DemandDetailData {
  final List<TransactionItem> transactionList;

  DemandDetailData({
    required this.transactionList,
  });

  factory DemandDetailData.fromJson(Map<String, dynamic> json) {
    return DemandDetailData(
      transactionList: (json['transactionList'] as List)
          .map((item) => TransactionItem.fromJson(item))
          .toList(),
    );
  }
}

class TransactionItem {
  final String transactionUniqueNo;
  final String transactionDate;
  final String transactionTime;
  final String transactionType;
  final String transactionTypeName;
  final String transactionAccountNo;
  final String transactionBalance;
  final String transactionAfterBalance;
  final String transactionSummary;
  final String transactionMemo;

  TransactionItem({
    required this.transactionUniqueNo,
    required this.transactionDate,
    required this.transactionTime,
    required this.transactionType,
    required this.transactionTypeName,
    required this.transactionAccountNo,
    required this.transactionBalance,
    required this.transactionAfterBalance,
    required this.transactionSummary,
    required this.transactionMemo,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      transactionUniqueNo: json['transactionUniqueNo'],
      transactionDate: json['transactionDate'],
      transactionTime: json['transactionTime'],
      transactionType: json['transactionType'],
      transactionTypeName: json['transactionTypeName'],
      transactionAccountNo: json['transactionAccountNo'] ?? '',
      transactionBalance: json['transactionBalance'],
      transactionAfterBalance: json['transactionAfterBalance'],
      transactionSummary: json['transactionSummary'],
      transactionMemo: json['transactionMemo'] ?? '',
    );
  }
}