import 'package:flutter/material.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/core/theme/app_colors.dart';

import 'package:marshmellow/presentation/pages/ledger/widgets/transaction_modal/transaction_form/transaction_field.dart';


class ExpenseForm extends StatelessWidget {
  const ExpenseForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          TransactionField(label: '카테고리', value: ''),
          TransactionField(label: '상호명', value: ''),
          TransactionField(label: '결제수단', value: ''),
          TransactionField(label: '날짜', value: ''),
          TransactionField(label: '메모/키워드', value: ''),
          TransactionField(
            label: '예산에서 제외',
            value: '',
            showDivider: false,
          ),
         
        ],
      ),
    );
  }
}
