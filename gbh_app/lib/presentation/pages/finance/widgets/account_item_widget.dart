// presentation/pages/finance/widgets/account_item_widget.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/core/constants/icon_path.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:marshmellow/router/routes/finance_routes.dart';

class AccountItemWidget extends StatelessWidget {
  final String bankName; // 은행명
  final String accountName; // 계좌 명
  final String accountNo; // 계좌번호
  final int balance; // 계좌잔액
  final bool isLoan; // 대출정보 여부
  final bool noMoneyMan; // 송금가능여부
  final String type; // 입출금, 예금, 적금, 대출

  const AccountItemWidget({
    Key? key,
    required this.bankName,
    required this.accountName,
    required this.accountNo,
    required this.balance,
    this.isLoan = false,
    this.noMoneyMan = false,
    required this.type,
  }) : super(key: key);

  // 숫자 포맷팅 함수 (천 단위 구분)
  String formatAmount(int amount) {
    final formatter = NumberFormat('#,###');
    return formatter.format(amount);
  }
  bool _isPngPath(String path) {
    return path.endsWith('.png');
  }

  // 계좌번호 마스킹 함수
  // String _maskAccountNumber(String accountNo) {
  //   if (accountNo.length < 6) return accountNo;
  //   return '${accountNo.substring(0, 3)}****${accountNo.substring(accountNo.length - 4)}';
  // }

  // 은행 이름에 따라 아이콘 경로를 반환하는 메서드
  String _getBankIconPath(String bankName) {
    switch (bankName.toLowerCase()) {
      case "한국은행":
      case "korea bank":
        return IconPath.koreaBank2;
      case "산업은행":
      case "kdb bank":
        return IconPath.kdbBank;
      case "기업은행":
      case "ibk bank":
        return IconPath.ibkBank;
      case "국민은행":
      case "kb bank":
        return IconPath.kbBank;
      case "농협은행":
      case "nh bank":
        return IconPath.nhBank;
      case "우리은행":
      case "woori bank":
        return IconPath.wooriBank;
      case "sc제일은행":
      case "standard chartered bank":
      case "sc bank":
        return IconPath.scBank;
      case "시티은행":
      case "citi bank":
        return IconPath.citiBank;
      case "대구은행":
      case "daegu bank":
        return IconPath.dgBank;
      case "광주은행":
      case "gwangju bank":
        return IconPath.gjBank;
      case "제주은행":
      case "jeju bank":
        return IconPath.jejuBank;
      case "전북은행":
      case "jeonbuk bank":
        return IconPath.jbBank;
      case "경남은행":
      case "gyeongnam bank":
        return IconPath.gnBank;
      case "새마을금고":
      case "mg":
        return IconPath.mgBank;
      case "하나은행":
      case "hana bank":
        return IconPath.hanaBank;
      case "신한은행":
      case "shinhan bank":
        return IconPath.shinhanBank;
      case "카카오뱅크":
      case "kakao bank":
        return IconPath.kakaoBank;
      case "싸피뱅크":
      case "ssafy bank":
      case "toss bank":
        return IconPath.ssafyBank2;
      default:
        return IconPath.ibkBank; // 기본값으로 IBK 아이콘 사용
    }
  }
  Widget _buildBankIcon(String bankName) {
    final String iconPath = _getBankIconPath(bankName);
    
    if (_isPngPath(iconPath)) {
      return Image.asset(
        iconPath,
        width: 40, // 원하는 크기로 조정
        height: 40,
      );
    } else {
      return SvgPicture.asset(
        iconPath,
        width: 40, // 원하는 크기로 조정
        height: 40,
      );
    }
  }
  // AccountItemWidget.dart의 onTap 처리 메서드 예시
  void _onAccountItemTap(BuildContext context) {
    // type에 따라 다른 경로로 이동
    switch (type) {
      case '입출금':
        context.push(
          FinanceRoutes.getDemandDetailPath(accountNo),
          extra: {
            'bankName': bankName,
            'accountName': accountName,
            'accountNo': accountNo,
            'balance': balance,
            'noMoneyMan': noMoneyMan,
          },
        );
        break;
      case '예금':
        // 예금 상세 페이지로 이동 (아직 구현되지 않음)
        context.push(
          FinanceRoutes.getDepositDetailPath(accountNo),
          extra: {
            'bankName': bankName,
            'accountName': accountName,
            'accountNo': accountNo,
            'balance': balance,
            'noMoneyMan': noMoneyMan,
          },
        );
        break;
      case '적금':
        // 적금 상세 페이지로 이동 (아직 구현되지 않음)
        context.push(FinanceRoutes.getSavingDetailPath(accountNo));
        break;
      case '대출':
        // 대출 상세 페이지로 이동 (아직 구현되지 않음)
        context.push(FinanceRoutes.getLoanDetailPath(accountNo));
        break;
      default:
        // 기본 처리 (필요시)
        break;
    }
  }


@override
Widget build(BuildContext context) {
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade300),
      borderRadius: BorderRadius.circular(8),
    ),
    child: ClipRRect( // 효과를 컨테이너 내부로 제한
      borderRadius: BorderRadius.circular(8),
      child: Material( // Material 위젯 추가
        color: Colors.transparent,
        child: InkWell(
// <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< 상세페이지 테스트중 <<<<<<<<<<<<<<<<<<<<<<<<<
          onTap: () {
            _onAccountItemTap(context);
          },
// >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 상세페이지 테스트중 >>>>>>>>>>>>>>>>>>>>>>>>>>
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 8.0, 14.0, 8.0),
          child: Row(
            children: [
              IconButton(
              icon: _buildBankIcon(bankName),
// <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< 상세페이지 테스트중 <<<<<<<<<<<<<<<<<<<<<<<<<
              onPressed: () {
                _onAccountItemTap(context);
              },
// >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 상세페이지 테스트중 >>>>>>>>>>>>>>>>>>>>>>>>>>
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text('타입: $type'),
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
                ? GestureDetector(
// <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< 상세페이지 테스트중 <<<<<<<<<<<<<<<<<<<<<<<<<
                    onTap: () {
                      context.push(FinanceRoutes.getTransferPath()); 
                    },
// >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 상세페이지 테스트중 >>>>>>>>>>>>>>>>>>>>>>>>>>
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      // margin: EdgeInsets.fromLTRB(0.0, 0.0, 6.0, 0.0),
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
// <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< 상세페이지 테스트중 <<<<<<<<<<<<<<<<<<<<<<<<<
                    onPressed: () {
                      _onAccountItemTap(context);
                    },
// >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> 상세페이지 테스트중 >>>>>>>>>>>>>>>>>>>>>>>>>>
                  ),
            ],
          ),),),
        ),
      ),
    );
  }
}