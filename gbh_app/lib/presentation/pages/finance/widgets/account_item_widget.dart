// presentation/pages/finance/widgets/account_item_widget.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/core/constants/icon_path.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AccountItemWidget extends StatelessWidget {
  final String bankName;
  final String accountName;
  final String accountNo;
  final int balance;
  final bool isLoan;
  final bool noMoneyMan;

  const AccountItemWidget({
    Key? key,
    required this.bankName,
    required this.accountName,
    required this.accountNo,
    required this.balance,
    this.isLoan = false,
    this.noMoneyMan = false,
  }) : super(key: key);

  // 숫자 포맷팅 함수 (천 단위 구분)
  String formatAmount(int amount) {
    final formatter = NumberFormat('#,###');
    return formatter.format(amount);
  }

  // 계좌번호 마스킹 함수
  // String _maskAccountNumber(String accountNo) {
  //   if (accountNo.length < 6) return accountNo;
  //   return '${accountNo.substring(0, 3)}****${accountNo.substring(accountNo.length - 4)}';
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          IconButton(
            icon: SvgPicture.asset(IconPath.ibkBank),
            onPressed: () {},
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  accountName,
                  style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600,
                  color: AppColors.blackLight)
                ),
                // if (bankName != '-') Text('은행: $bankName'),
                // Text('계좌번호: ${_maskAccountNumber(accountNo)}'),
                Text(
                  isLoan ? '대출금액 ${formatAmount(balance)}원' : '${formatAmount(balance)}원',
                  style: AppTextStyles.subTitle
                ),
              ],
            ),
          ),
          noMoneyMan
            ? InkWell(
                onTap: () {
                  // 송금 기능 실행
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  margin: EdgeInsets.fromLTRB(0.0, 0.0, 6.0, 0.0),
                  decoration: BoxDecoration(
                    color: AppColors.buttonBlack,
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Text(
                    "송금",
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.background)
                    // style: AppTextStyles.buttonBold.copyWith(color: AppColors.background)
                    // style: AppTextStyles.button.copyWith(color: AppColors.background)
                  ),
                ),
              )
            : IconButton(
                icon: Icon(Icons.arrow_forward_ios, size: 16),
                onPressed: () {},
              ),
        ],
      ),
    );
  }
}