// 송금 요청 모델
class TransferRequest {
  final int withdrawalAccountId;
  final String depositAccountNo;
  final String transactionSummary;
  final int transactionBalance;

  TransferRequest({
    required this.withdrawalAccountId,
    required this.depositAccountNo,
    required this.transactionSummary,
    required this.transactionBalance,
  });

  Map<String, dynamic> toJson() {
    return {
      'withdrawalAccountId': withdrawalAccountId,
      'depositAccountNo': depositAccountNo,
      'transactionSummary': transactionSummary,
      'transactionBalance': transactionBalance,
    };
  }
}

// 송금 응답 모델
class TransferResponse {
  final int code;
  final String message;
  final TransferData data;

  TransferResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory TransferResponse.fromJson(Map<String, dynamic> json) {
    return TransferResponse(
      code: json['code'],
      message: json['message'],
      data: TransferData.fromJson(json['data']),
    );
  }
}

// 송금 응답 데이터
class TransferData {
  final String message;

  TransferData({
    required this.message,
  });

  factory TransferData.fromJson(Map<String, dynamic> json) {
    return TransferData(
      message: json['message'],
    );
  }
}

// 은행 모델
class Bank {
  final String code;
  final String name;
  final String iconPath;

  Bank({
    required this.code,
    required this.name,
    required this.iconPath,
  });
}