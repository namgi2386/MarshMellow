import 'package:marshmellow/data/models/ledger/category/transaction_category.dart';

enum TransactionClassification {
  DEPOSIT,   // 수입
  WITHDRAWAL, // 지출
  TRANSFER   // 이체
}

class Transaction {
  final int householdPk;           // 가계부 고유번호
  final String tradeName;          // 거래처 명
  final String tradeDate;          // 거래일 (yyyyMMdd 형식)
  final String tradeTime;          // 거래시간 (hhMM 형식)
  final int householdAmount;       // 사용금액
  final String? householdMemo;     // 메모 (API에서는 없지만 앱에서 필요할 수 있음)
  final String paymentMethod;      // 결제수단
  final String paymentCancelYn;    // 거래 취소 여부 (Y 또는 N)
  final String householdCategory;  // 가계부 메인 카테고리
  final String? householdDetailCategory; // 가계부 상세 카테고리 (API에서는 없지만 앱에서 필요할 수 있음)
  final TransactionClassification classification; // 가계부 분류 (DEPOSIT, WITHDRAWAL, TRANSFER)

  Transaction({
    required this.householdPk,
    required this.tradeName,
    required this.tradeDate,
    required this.tradeTime,
    required this.householdAmount,
    this.householdMemo,
    required this.paymentMethod,
    required this.paymentCancelYn,
    required this.householdCategory,
    this.householdDetailCategory,
    required this.classification,
  });

  // API 응답에서 Transaction 객체 생성 - 명세서에 맞게 수정
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      householdPk: json['householdPk'],
      tradeName: json['tradeName'],
      tradeDate: json['tradeDate'],
      tradeTime: json['tradeTime'],
      householdAmount: json['householdAmount'],
      householdMemo: null, // API에서 제공하지 않음
      paymentMethod: json['paymentMethod'],
      paymentCancelYn: json['paymentCancelYn'],
      householdCategory: json['householdCategory'],
      householdDetailCategory: null, // API에서 제공하지 않음
      classification: _parseClassification(json['householdClassificationCategory']),
    );
  }

  // 문자열을 TransactionClassification 열거형으로 변환
  static TransactionClassification _parseClassification(String value) {
    switch (value) {
      case 'DEPOSIT':
        return TransactionClassification.DEPOSIT;
      case 'WITHDRAWAL':
        return TransactionClassification.WITHDRAWAL;
      case 'TRANSFER':
        return TransactionClassification.TRANSFER;
      default:
        return TransactionClassification.WITHDRAWAL; // 기본값
    }
  }

  // DateTime 형식으로 거래일자 반환 (필요시 사용)
  DateTime get dateTime {
    final year = int.parse(tradeDate.substring(0, 4));
    final month = int.parse(tradeDate.substring(4, 6));
    final day = int.parse(tradeDate.substring(6, 8));
    final hour = int.parse(tradeTime.substring(0, 2));
    final minute = int.parse(tradeTime.substring(2, 4));
    
    return DateTime(year, month, day, hour, minute);
  }

  // JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'householdPk': householdPk,
      'tradeName': tradeName,
      'tradeDate': tradeDate,
      'tradeTime': tradeTime,
      'householdAmount': householdAmount,
      'householdMemo': householdMemo,
      'paymentMethod': paymentMethod,
      'paymentCancelYn': paymentCancelYn,
      'householdCategory': householdCategory,
      'householdDetailCategory': householdDetailCategory,
      'householdClassificationCategory': _classificationToString(classification),
    };
  }

  // TransactionClassification 열거형을 문자열로 변환
  static String _classificationToString(TransactionClassification classification) {
    switch (classification) {
      case TransactionClassification.DEPOSIT:
        return 'DEPOSIT';
      case TransactionClassification.WITHDRAWAL:
        return 'WITHDRAWAL';
      case TransactionClassification.TRANSFER:
        return 'TRANSFER';
    }
  }

  // TransactionListItem 위젯과 호환되도록 추가하는 getter 메서드들
String get title => tradeName;
double get amount => householdAmount.toDouble();
String? get accountName => null; // API에 없는 정보는 null 반환

// 트랜잭션 타입 반환 (TransactionCategory 클래스와 호환되도록)
TransactionType get type {
  switch (classification) {
    case TransactionClassification.DEPOSIT:
      return TransactionType.deposit;
    case TransactionClassification.WITHDRAWAL:
      return TransactionType.withdrawal;
    case TransactionClassification.TRANSFER:
      return TransactionType.transfer;
  }
}

// 카테고리 ID 반환 (TransactionListItem에서 필요)
String get categoryId => householdCategory;

// 트랜잭션 ID (TransactionListItem에서 필요)
int get id => householdPk;

}