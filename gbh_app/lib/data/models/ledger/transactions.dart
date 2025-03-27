// data/models/finance/transaction.dart
import 'package:marshmellow/data/models/ledger/transaction_category.dart';

class Transaction {
  final String id;
  final DateTime date;
  final String title;
  final String? description;
  final double amount;
  final TransactionType type; // 수입 또는 지출
  final dynamic categoryId; // 카테고리 ID (ExpenseCategoryType 또는 IncomeCategoryType)
  final String? paymentMethod; // 결제 수단 (현금, 신용카드 등)
  final String? accountName; // 계좌 또는 카드명

  Transaction({
    required this.id,
    required this.date,
    required this.title,
    this.description,
    required this.amount,
    required this.type,
    required this.categoryId,
    this.paymentMethod,
    this.accountName,
  });
}