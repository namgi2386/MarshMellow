// presentation/pages/finance/widgets/total_assets_widget.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TotalAssetsWidget extends StatelessWidget {
  final int totalAssets;
  
  const TotalAssetsWidget({
    Key? key,
    required this.totalAssets,
  }) : super(key: key);
  
  // 숫자 포맷팅 함수 (천 단위 구분)
  String formatAmount(int amount) {
    final formatter = NumberFormat('#,###');
    return formatter.format(amount);
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '총 자산',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '${formatAmount(totalAssets)}원',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}