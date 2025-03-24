// 입출금 계좌 모델
class DemandDepositData {
  final int totalAmount;
  final List<DemandDepositItem> demandDepositList;

  DemandDepositData({
    required this.totalAmount,
    required this.demandDepositList,
  });

  factory DemandDepositData.fromJson(Map<String, dynamic> json) {
    return DemandDepositData(
      totalAmount: json['totalAmount'],
      demandDepositList: (json['demandDepositList'] as List)
          .map((item) => DemandDepositItem.fromJson(item))
          .toList(),
    );
  }
}

class DemandDepositItem {
  final String bankCode;
  final String bankName;
  final String accountNo;
  final String accountName;
  final int accountBalance;

  DemandDepositItem({
    required this.bankCode,
    required this.bankName,
    required this.accountNo,
    required this.accountName,
    required this.accountBalance,
  });

  factory DemandDepositItem.fromJson(Map<String, dynamic> json) {
    return DemandDepositItem(
      bankCode: json['bankCode'],
      bankName: json['bankName'],
      accountNo: json['accountNo'],
      accountName: json['accountName'],
      accountBalance: json['accountBalance'],
    );
  }
}

// 대출 모델
class LoanData {
  final int totalAmount;
  final List<LoanItem> loanList;

  LoanData({
    required this.totalAmount,
    required this.loanList,
  });

  factory LoanData.fromJson(Map<String, dynamic> json) {
    return LoanData(
      totalAmount: json['totalAmount'],
      loanList: (json['loanList'] as List)
          .map((item) => LoanItem.fromJson(item))
          .toList(),
    );
  }
}

class LoanItem {
  final String accountNo;
  final String accountName;
  final int loanBalance;

  LoanItem({
    required this.accountNo,
    required this.accountName,
    required this.loanBalance,
  });

  factory LoanItem.fromJson(Map<String, dynamic> json) {
    return LoanItem(
      accountNo: json['accountNo'],
      accountName: json['accountName'],
      loanBalance: json['loanBalance'],
    );
  }
}

// 적금 모델
class SavingsData {
  final int totalAmount;
  final List<SavingsItem> savingsList;

  SavingsData({
    required this.totalAmount,
    required this.savingsList,
  });

  factory SavingsData.fromJson(Map<String, dynamic> json) {
    return SavingsData(
      totalAmount: json['totalAmount'],
      savingsList: (json['savingsList'] as List)
          .map((item) => SavingsItem.fromJson(item))
          .toList(),
    );
  }
}

class SavingsItem {
  final String bankCode;
  final String bankName;
  final String accountNo;
  final String accountName;
  final int totalBalance;

  SavingsItem({
    required this.bankCode,
    required this.bankName,
    required this.accountNo,
    required this.accountName,
    required this.totalBalance,
  });

  factory SavingsItem.fromJson(Map<String, dynamic> json) {
    return SavingsItem(
      bankCode: json['bankCode'],
      bankName: json['bankName'],
      accountNo: json['accountNo'],
      accountName: json['accountName'],
      totalBalance: json['totalBalance'],
    );
  }
}

// 예금 모델
class DepositData {
  final int totalAmount;
  final List<DepositItem> depositList;

  DepositData({
    required this.totalAmount,
    required this.depositList,
  });

  factory DepositData.fromJson(Map<String, dynamic> json) {
    return DepositData(
      totalAmount: json['totalAmount'],
      depositList: (json['depositList'] as List)
          .map((item) => DepositItem.fromJson(item))
          .toList(),
    );
  }
}

class DepositItem {
  final String bankCode;
  final String bankName;
  final String accountNo;
  final String accountName;
  final int depositBalance;

  DepositItem({
    required this.bankCode,
    required this.bankName,
    required this.accountNo,
    required this.accountName,
    required this.depositBalance,
  });

  factory DepositItem.fromJson(Map<String, dynamic> json) {
    return DepositItem(
      bankCode: json['bankCode'],
      bankName: json['bankName'],
      accountNo: json['accountNo'],
      accountName: json['accountName'],
      depositBalance: json['depositBalance'],
    );
  }
}