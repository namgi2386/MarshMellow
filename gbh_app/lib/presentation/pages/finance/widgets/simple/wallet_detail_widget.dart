// presentation/pages/finance/widgets/wallet_detail_widget.dart
import 'package:flutter/material.dart';

class WalletDetailWidget extends StatelessWidget {
  final String? walletType;
  final Map<String, dynamic>? walletData;
  final VoidCallback onBackPressed;

  const WalletDetailWidget({
    Key? key,
    required this.walletType,
    required this.walletData,
    required this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 선택된 정보가 없으면 기본 메시지 표시
    if (walletType == null || walletData == null) {
      return Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: const Text('지갑 정보를 불러올 수 없습니다.'),
      );
    }

    // 선택된 지갑 정보 사용
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$walletType 상세 정보',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                '총액: ${walletData!['totalAmount']}원',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 자산 추가하기는 목록이 없으므로 다르게 처리
          if (walletType == '자산 추가하기')
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_circle_outline, size: 64, color: Colors.blue.shade300),
                  const SizedBox(height: 16),
                  Text('새로운 자산을 추가해보세요', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // 여기에 자산 추가 로직 구현
                      print('자산 추가 버튼 클릭됨');
                    },
                    child: Text('자산 추가하기'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(200, 48),
                    ),
                  ),
                ],
              ),
            )
          else
            _buildWalletItemsList(),
          
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onBackPressed,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('뒤로'),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletItemsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: (walletData!['list'] as List).length,
      itemBuilder: (context, index) {
        final item = (walletData!['list'] as List)[index];
        
        // 지갑 유형에 따라 다른 필드 사용
        String title = '';
        String subtitle = '';
        String amount = '';
        
        switch (walletType) {
          case '입출금':
            title = item.accountName;
            subtitle = item.bankName;
            amount = '${item.accountBalance}원';
            break;
          case '예금':
            title = item.accountName;
            subtitle = item.bankName;
            amount = '${item.depositBalance}원';
            break;
          case '적금':
            title = item.accountName;
            subtitle = item.bankName;
            amount = '${item.totalBalance}원';
            break;
          case '카드':
            title = item.cardIssuerName;
            subtitle = item.cardName;
            amount = '${item.cardBalance}원';
            break;
          case '대출':
            title = item.accountName;
            subtitle = "대출 상품";  // 대출에는 bankName이 없다고 가정
            amount = '${item.loanBalance}원';
            break;
          default:
            title = '알 수 없음';
            subtitle = '정보 없음';
            amount = '0원';
        }
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(title),
            subtitle: Text(subtitle),
            trailing: Text(amount, 
              style: TextStyle(
                fontWeight: FontWeight.bold,
                // 대출은 빨간색으로 표시
                color: walletType == '대출' ? Colors.red : Colors.black,
              )
            ),
          ),
        );
      },
    );
  }
}