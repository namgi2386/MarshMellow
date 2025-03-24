// presentation/pages/finance/widgets/account_item_widget.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AccountItemWidget extends StatelessWidget {
  final String bankName;
  final String accountName;
  final String accountNo;
  final int balance;
  final bool isLoan;

  const AccountItemWidget({
    Key? key,
    required this.bankName,
    required this.accountName,
    required this.accountNo,
    required this.balance,
    this.isLoan = false,
  }) : super(key: key);

  // 숫자 포맷팅 함수 (천 단위 구분)
  String formatAmount(int amount) {
    final formatter = NumberFormat('#,###');
    return formatter.format(amount);
  }

  // 계좌번호 마스킹 함수
  String _maskAccountNumber(String accountNo) {
    if (accountNo.length < 6) return accountNo;
    return '${accountNo.substring(0, 3)}****${accountNo.substring(accountNo.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            accountName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          if (bankName != '-') Text('은행: $bankName'),
          Text('계좌번호: ${_maskAccountNumber(accountNo)}'),
          Text(
            '${isLoan ? '대출금액' : '잔액'}: ${formatAmount(balance)}원',
            style: TextStyle(
              color: isLoan ? Colors.red : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}