import 'package:flutter/material.dart';

import 'package:marshmellow/presentation/pages/ledger/widgets/transaction_modal/transaction_form/transaction_field.dart';

class IncomeForm extends StatelessWidget {
  const IncomeForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          TransactionField(
            label: '카테고리',
          ),
          TransactionField(label: '상호명', value: ''),
          TransactionField(label: '계좌', value: ''),
          TransactionField(label: '날짜', value: ''),
          TransactionField(label: '메모/키워드', value: ''),
        ],
      ),
    );
  }
}
