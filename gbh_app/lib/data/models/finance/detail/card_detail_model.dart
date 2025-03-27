// lib/data/models/finance/card_detail_model.dart

class CardDetailResponse {
  final int code;
  final String message;
  final CardDetailData data;

  CardDetailResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory CardDetailResponse.fromJson(Map<String, dynamic> json) {
    return CardDetailResponse(
      code: json['code'],
      message: json['message'],
      data: CardDetailData.fromJson(json['data']),
    );
  }
}

class CardDetailData {
  final int estimatedBalance;
  final List<CardTransactionItem> transactionList;

  CardDetailData({
    required this.estimatedBalance,
    required this.transactionList,
  });

  factory CardDetailData.fromJson(Map<String, dynamic> json) {
    return CardDetailData(
      estimatedBalance: json['estimatedBalance'],
      transactionList: (json['transactionList'] as List)
          .map((item) => CardTransactionItem.fromJson(item))
          .toList(),
    );
  }
}

class CardTransactionItem {
  final String transactionUniqueNo;
  final String merchantId;
  final String billStatementsStatus;
  final String billStatementsYn;
  final String transactionBalance;
  final String transactionDate;
  final String transactionTime;
  final String categoryName;
  final String categoryId;
  final String cardStatus;
  final String merchantName;

  CardTransactionItem({
    required this.transactionUniqueNo,
    required this.merchantId,
    required this.billStatementsStatus,
    required this.billStatementsYn,
    required this.transactionBalance,
    required this.transactionDate,
    required this.transactionTime,
    required this.categoryName,
    required this.categoryId,
    required this.cardStatus,
    required this.merchantName,
  });

  factory CardTransactionItem.fromJson(Map<String, dynamic> json) {
    return CardTransactionItem(
      transactionUniqueNo: json['transactionUniqueNo'],
      merchantId: json['merchantId'],
      billStatementsStatus: json['billStatementsStatus'],
      billStatementsYn: json['billStatementsYn'],
      transactionBalance: json['transactionBalance'],
      transactionDate: json['transactionDate'],
      transactionTime: json['transactionTime'],
      categoryName: json['categoryName'],
      categoryId: json['categoryId'],
      cardStatus: json['cardStatus'],
      merchantName: json['merchantName'],
    );
  }
}