// lib/presentation/pages/finance/saving_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:marshmellow/data/models/finance/detail/saving_detail_model.dart';
import 'package:marshmellow/presentation/viewmodels/finance/saving_detail_viewmodel.dart';

class SavingDetailPage extends ConsumerWidget {
  final String accountNo;
  final String bankName;
  final String accountName;
  final int balance;
  final bool noMoneyMan;

  const SavingDetailPage({
    Key? key,
    required this.accountNo,
    required this.bankName,
    required this.accountName,
    required this.balance,
    required this.noMoneyMan,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 계좌번호로 적금 납입내역 조회
    final paymentsAsync = ref.watch(savingPaymentsProvider(accountNo));
    
    return Scaffold(
      appBar: AppBar(
        title: Text('$bankName - $accountName'),
      ),
      body: paymentsAsync.when(
        data: (response) {
          // 데이터가 있는 경우
          if (response.data.paymentList.isEmpty) {
            return const Center(
              child: Text('납입 내역이 없습니다.'),
            );
          }
          
          // 첫 번째 적금 정보 가져오기 (API 응답에서 하나의 적금만 반환된다고 가정)
          final savingItem = response.data.paymentList[0];
          
          return Column(
            children: [
              _buildSavingHeader(savingItem),
              Expanded(
                child: _buildPaymentList(savingItem.paymentInfo),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('오류가 발생했습니다: $error'),
        ),
      ),
    );
  }

  // 적금 계좌 정보 헤더
  Widget _buildSavingHeader(SavingPaymentItem item) {
    final createDate = _formatDateForDisplay(item.accountCreateDate);
    final expiryDate = _formatDateForDisplay(item.accountExpiryDate);
    final formatter = NumberFormat('#,###');
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.accountName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            item.accountNo,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('적금 금리', '연 ${item.interestRate}%'),
          _buildInfoRow('월 납입액', '${formatter.format(int.parse(item.depositBalance))}원'),
          _buildInfoRow('납입 총액', '${formatter.format(int.parse(item.totalBalance))}원'),
          _buildInfoRow('가입일', createDate),
          _buildInfoRow('만기일', expiryDate),
        ],
      ),
    );
  }

  // 정보 행 위젯
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // 납입 내역 리스트
  Widget _buildPaymentList(List<PaymentInfoItem> payments) {
    return Container(
      color: Colors.grey[100],
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: payments.length,
        itemBuilder: (context, index) {
          final payment = payments[index];
          final formatter = NumberFormat('#,###');
          final formattedDate = _formatDateForDisplay(payment.paymentDate);
          final formattedTime = _formatTimeForDisplay(payment.paymentTime);
          
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${payment.depositInstallment}회차 납입',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _buildStatusChip(payment.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$formattedDate $formattedTime',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${formatter.format(int.parse(payment.paymentBalance))}원',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  if (payment.failureReason != null && payment.failureReason!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '실패 사유: ${payment.failureReason}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // 상태 칩 위젯
  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    
    if (status == 'SUCCESS') {
      color = Colors.green;
      label = '성공';
    } else {
      color = Colors.red;
      label = '실패';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // 날짜 포맷 변환 (20250321 -> 2025.03.21)
  String _formatDateForDisplay(String dateStr) {
    if (dateStr.length != 8) return dateStr;
    
    final year = dateStr.substring(0, 4);
    final month = dateStr.substring(4, 6);
    final day = dateStr.substring(6, 8);
    return '$year.$month.$day';
  }

  // 시간 포맷 변환 (151915 -> 15:19)
  String _formatTimeForDisplay(String timeStr) {
    if (timeStr.length < 4) return timeStr;
    
    final hour = timeStr.substring(0, 2);
    final minute = timeStr.substring(2, 4);
    return '$hour:$minute';
  }
}