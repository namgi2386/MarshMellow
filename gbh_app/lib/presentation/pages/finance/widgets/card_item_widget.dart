// presentation/pages/finance/widgets/card_item_widget.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/data/models/finance/card_model.dart';
import 'package:marshmellow/presentation/widgets/finance/card_image_util.dart';
import 'package:marshmellow/router/routes/finance_routes.dart';


class CardItemWidget extends StatelessWidget {
  final CardItem card;

  const CardItemWidget({
    Key? key,
    required this.card,
  }) : super(key: key);

  // 숫자 포맷팅 함수 (천 단위 구분)
  String formatAmount(int amount) {
    final formatter = NumberFormat('#,###');
    return formatter.format(amount);
  }

  // 카드번호 마스킹 함수
  String _maskCardNumber(String cardNo) {
    if (cardNo.length < 8) return cardNo;
    return '${cardNo.substring(0, 4)} **** **** ${cardNo.substring(cardNo.length - 4)}';
  }

  // CardItemWidget.dart의 onTap 처리 메서드 예시
  void _onCardItemTap(BuildContext context) {
    context.push(
      FinanceRoutes.getCardDetailPath(card.cardNo),
      extra: {
        'bankName': card.cardIssuerName,
        'cardName': card.cardName,
        'cardNo': card.cardNo,
        'cvc': card.cvc,
        'balance': card.cardBalance,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _onCardItemTap(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // 주 축에서 공간을 균등하게 분배
          children: [
            // 이미지 영역
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.2, // 화면 너비의 20%
              child: Center(
                child: CardImageUtil.getCardImageWidget(card.cardName, size: 64),
              ),
            ),
            // 텍스트 영역
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.55, // 화면 너비의 55% (패딩 고려)
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.cardName,
                    style: AppTextStyles.subTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text('${_maskCardNumber(card.cardNo)}', style: AppTextStyles.bodySmall),
                  Text('${formatAmount(card.cardBalance)}원 지출', style: AppTextStyles.subTitle),
                ],
              ),
            ),
            // 아이콘 영역
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.05, // 화면 너비의 5%
              child: Center(
                child: Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
