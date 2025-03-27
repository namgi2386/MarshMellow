// lib/presentation/pages/finance/deposit_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:marshmellow/data/models/finance/detail/deposit_detail_model.dart';
import 'package:marshmellow/presentation/viewmodels/finance/deposit_detail_viewmodel.dart';

class DepositDetailPage extends ConsumerWidget {
  final String accountNo;
  final String bankName;
  final String accountName;
  final int balance;
  final bool noMoneyMan;

  const DepositDetailPage({
    Key? key,
    required this.accountNo,
    required this.bankName,
    required this.accountName,
    required this.balance,
    required this.noMoneyMan,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final depositPaymentAsync = ref.watch(depositPaymentProvider(accountNo));
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${bankName} - ${accountName}'),
      ),
      body: Column(
        children: [
          _buildAccountHeader(),
          Expanded(
            child: depositPaymentAsync.when(
              data: (response) => _buildPaymentDetails(response.data.payment),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('오류가 발생했습니다: $error')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            accountName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            accountNo,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('현재 잔액', style: TextStyle(fontSize: 14)),
              Text(
                '${NumberFormat('#,###').format(balance)}원',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetails(PaymentItem payment) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '예금 납입 정보',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDetailRow('납입 번호', payment.paymentUniqueNo),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    '납입 일시', 
                    _formatDateTime(payment.paymentDate, payment.paymentTime)
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    '납입 금액', 
                    '${NumberFormat('#,###').format(int.parse(payment.paymentBalance))}원'
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '예금 정보',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDetailRow('은행명', bankName),
                  const SizedBox(height: 8),
                  _buildDetailRow('계좌명', accountName),
                  const SizedBox(height: 8),
                  _buildDetailRow('계좌번호', accountNo),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    '현재 잔액', 
                    '${NumberFormat('#,###').format(balance)}원'
                  ),
                  // 예금 만기일, 이자율 등 추가 정보가 있다면 여기에 추가
                ],
              ),
            ),
          ),
          // const Spacer(),
          // SizedBox(
          //   width: double.infinity,
          //   child: ElevatedButton(
          //     onPressed: () {
          //       // 송금 기능이 있을 경우 처리
          //       if (!noMoneyMan) {
          //         // 송금 페이지로 이동하거나 다이얼로그 표시
          //         ScaffoldMessenger.of(context).showSnackBar(
          //           const SnackBar(content: Text('송금 기능은 현재 구현되지 않았습니다.')),
          //         );
          //       } else {
          //         ScaffoldMessenger.of(context).showSnackBar(
          //           const SnackBar(content: Text('이 계좌는 송금이 불가능합니다.')),
          //         );
          //       }
          //     },
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: noMoneyMan ? Colors.grey : Colors.blue,
          //       padding: const EdgeInsets.symmetric(vertical: 16),
          //     ),
          //     child: const Text('송금하기'),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(
          value, 
          style: const TextStyle(fontWeight: FontWeight.bold)
        ),
      ],
    );
  }

  String _formatDateTime(String date, String time) {
    // 날짜 형식: YYYYMMDD, 시간 형식: HHMMSS
    final year = date.substring(0, 4);
    final month = date.substring(4, 6);
    final day = date.substring(6, 8);
    
    final hour = time.substring(0, 2);
    final minute = time.substring(2, 4);
    final second = time.substring(4, 6);
    
    return '$year.$month.$day $hour:$minute';
  }
}