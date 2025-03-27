// lib/presentation/pages/finance/loan_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:marshmellow/data/models/finance/detail/loan_detail_model.dart';
import 'package:marshmellow/presentation/viewmodels/finance/loan_detail_viewmodel.dart';

class LoanDetailPage extends ConsumerWidget {
  final String accountNo;
  final String bankName;
  final String accountName;
  final int balance;

  const LoanDetailPage({
    Key? key,
    required this.accountNo,
    required this.bankName,
    required this.accountName,
    required this.balance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loanDetailsAsync = ref.watch(loanPaymentDetailsProvider(accountNo));
    
    return Scaffold(
      appBar: AppBar(
        title: Text('$bankName - $accountName'),
      ),
      body: loanDetailsAsync.when(
        data: (response) => _buildContent(context, response.data),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('오류가 발생했습니다: $error', textAlign: TextAlign.center),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, LoanDetailData data) {
    return Column(
      children: [
        _buildLoanHeader(data),
        Expanded(
          child: _buildRepaymentList(data.repaymentRecords),
        ),
      ],
    );
  }

  Widget _buildLoanHeader(LoanDetailData data) {
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
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('대출 상태', style: TextStyle(fontSize: 14)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: data.status == '연체' ? Colors.red.shade100 : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  data.status,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: data.status == '연체' ? Colors.red.shade900 : Colors.green.shade900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('대출금', style: TextStyle(fontSize: 14)),
              Text(
                '${NumberFormat('#,###').format(data.loanBalance)}원',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('남은 상환금액', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Text(
                '${NumberFormat('#,###').format(data.remainingLoanBalance)}원',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 8),
          const Text(
            '상환 내역',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildRepaymentList(List<RepaymentRecord> records) {
    if (records.isEmpty) {
      return const Center(
        child: Text('상환 내역이 없습니다.'),
      );
    }
    
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final record = records[index];
        final isSuccess = record.status == 'SUCCESS';
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${record.installmentNumber}회차',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSuccess ? Colors.green.shade100 : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isSuccess ? '상환 완료' : '상환 실패',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSuccess ? Colors.green.shade900 : Colors.red.shade900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '납부 예정일: ${_formatDate(record.repaymentAttemptDate)}',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              if (isSuccess) ...[
                Text(
                  '납부일: ${_formatDate(record.repaymentActualDate!)}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('납부금액: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      '${NumberFormat('#,###').format(int.parse(record.paymentBalance))}원',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ] else if (record.failureReason.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  '실패 사유: ${record.failureReason}',
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  String _formatDate(String dateStr) {
    final year = dateStr.substring(0, 4);
    final month = dateStr.substring(4, 6);
    final day = dateStr.substring(6, 8);
    return '$year.$month.$day';
  }
}