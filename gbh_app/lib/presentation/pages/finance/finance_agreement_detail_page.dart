// finance_agreement_detail_page.dart
import 'package:flutter/material.dart';
import 'package:marshmellow/presentation/widgets/custom_appbar/custom_appbar.dart';

class FinanceAgreementDetailPage extends StatelessWidget {
  final String agreementNo;

  const FinanceAgreementDetailPage({
    Key? key,
    required this.agreementNo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        title: '약관 상세',
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('약관 번호: $agreementNo', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            // 여기에 약관 내용이 들어갈 예정
            const Text('약관 내용은 추후 추가될 예정입니다.'),
          ],
        ),
      ),
    );
  }
}