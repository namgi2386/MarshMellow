// presentation/pages/finance/widgets/card_item_widget.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marshmellow/data/models/finance/card_model.dart';

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
            card.cardName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text('카드번호: ${_maskCardNumber(card.cardNo)}'),
          Text('발급사: ${card.cardIssuerName}'),
          Text('잔액: ${formatAmount(card.cardBalance)}원'),
        ],
      ),
    );
  }
}