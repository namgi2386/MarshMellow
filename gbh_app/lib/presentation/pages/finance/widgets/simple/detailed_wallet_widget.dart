// presentation/pages/finance/widgets/detailed_wallet_widget.dart
import 'package:flutter/material.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/presentation/pages/finance/widgets/simple/real_wallet_widget.dart';

class DetailedWalletWidget extends StatelessWidget {
  final String walletType;
  final List<DemandDepositItem> items;
  final double totalAmount;
  final VoidCallback onClose;

  const DetailedWalletWidget({
    Key? key,
    required this.walletType,
    required this.items,
    required this.totalAmount,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.all(8.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  walletType,
                  style: AppTextStyles.appBar
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                ),
              ],
            ),
            const Divider(),
            
            // 총액 정보
            if (totalAmount >= 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  '총 ${walletType} 금액: ${totalAmount.toStringAsFixed(0)}원',
                  style: AppTextStyles.appBar,
                ),
              ),
            
            // 상세 아이템 리스트
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_circle_outline, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            '새로운 ${walletType}를 추가해보세요',
                            style: AppTextStyles.appBar,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          child: ListTile(
                            leading: Icon(Icons.account_balance),
                            title: Text(item.accountName),
                            subtitle: Text(item.bankName),
                            trailing: Text(
                              '${item.accountBalance.toStringAsFixed(0)}원',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: item.accountBalance < 0 ? Colors.red : Colors.black,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            
            // 하단 버튼
            if (walletType != '자산 추가하기')
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                    ),
                    onPressed: () {
                      // 상세 정보 페이지로 이동 또는 추가 액션
                    },
                    child: Text('${walletType} 관리하기'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}