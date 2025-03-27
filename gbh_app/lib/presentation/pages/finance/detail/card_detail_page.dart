// lib/presentation/pages/finance/card_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:marshmellow/data/models/finance/detail/card_detail_model.dart';
import 'package:marshmellow/presentation/viewmodels/finance/card_detail_viewmodel.dart';

class CardDetailPage extends ConsumerStatefulWidget {
  final String cardNo;
  final String bankName;
  final String cardName;
  final String cvc;
  final int balance;

  const CardDetailPage({
    Key? key,
    required this.cardNo,
    required this.bankName,
    required this.cardName,
    required this.cvc,
    required this.balance,
  }) : super(key: key);

  @override
  ConsumerState<CardDetailPage> createState() => _CardDetailPageState();
}

class _CardDetailPageState extends ConsumerState<CardDetailPage> {
  late String startDate;
  late String endDate;
  late CardDetailParams params;
  
  @override
  void initState() {
    super.initState();
    // 기본 조회 기간: 최근 1개월
    final now = DateTime.now();
    final oneMonthAgo = DateTime(now.year, now.month - 1, now.day);
    
    startDate = DateFormat('yyyyMMdd').format(oneMonthAgo);
    endDate = DateFormat('yyyyMMdd').format(now);
    
    // 초기 파라미터 설정
    _updateParams();
  }

  // 파라미터 갱신 메서드
  void _updateParams() {
    params = CardDetailParams(
      cardNo: widget.cardNo,
      cvc: widget.cvc,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(cardTransactionsProvider(params));
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.bankName} - ${widget.cardName}'),
      ),
      body: Column(
        children: [
          _buildCardHeader(),
          _buildDateSelector(),
          Expanded(
            child: transactionsAsync.when(
              data: (response) => _buildTransactionList(response.data.transactionList),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('오류가 발생했습니다: $error')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.cardName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '카드번호: ${_formatCardNumber(widget.cardNo)}',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('이번달 예상 청구금액', style: TextStyle(fontSize: 14)),
              Text(
                '${NumberFormat('#,###').format(widget.balance)}원',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 카드번호 형식화 (1234-5678-9012-3456)
  String _formatCardNumber(String cardNo) {
    if (cardNo.length != 16) return cardNo;
    return '${cardNo.substring(0, 4)}-${cardNo.substring(4, 8)}-${cardNo.substring(8, 12)}-${cardNo.substring(12, 16)}';
  }

  Widget _buildDateSelector() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _selectDate(context, true),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _formatDateForDisplay(startDate),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('~'),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _selectDate(context, false),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _formatDateForDisplay(endDate),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = _parseDate(isStartDate ? startDate : endDate);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        final formattedDate = DateFormat('yyyyMMdd').format(picked);
        if (isStartDate) {
          startDate = formattedDate;
        } else {
          endDate = formattedDate;
        }
        _updateParams(); // 날짜 변경 후 파라미터 갱신
      });
    }
  }

  DateTime _parseDate(String dateStr) {
    final year = int.parse(dateStr.substring(0, 4));
    final month = int.parse(dateStr.substring(4, 6));
    final day = int.parse(dateStr.substring(6, 8));
    return DateTime(year, month, day);
  }

  String _formatDateForDisplay(String dateStr) {
    final year = dateStr.substring(0, 4);
    final month = dateStr.substring(4, 6);
    final day = dateStr.substring(6, 8);
    return '$year.$month.$day';
  }

  Widget _buildTransactionList(List<CardTransactionItem> transactions) {
    if (transactions.isEmpty) {
      return const Center(
        child: Text('거래 내역이 없습니다.'),
      );
    }
    
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = transactions[index];
        final isApproved = item.cardStatus == '승인';
        
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _formatTransactionDate(item.transactionDate),
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  Text(_formatTransactionTime(item.transactionTime)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.merchantName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          item.categoryName,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${NumberFormat('#,###').format(int.parse(item.transactionBalance))}원',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isApproved ? Colors.red : Colors.blue,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isApproved ? Colors.red.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.cardStatus,
                          style: TextStyle(
                            fontSize: 12,
                            color: isApproved ? Colors.red : Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${item.billStatementsStatus}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTransactionDate(String dateStr) {
    final year = dateStr.substring(0, 4);
    final month = dateStr.substring(4, 6);
    final day = dateStr.substring(6, 8);
    return '$year.$month.$day';
  }

  String _formatTransactionTime(String timeStr) {
    final hour = timeStr.substring(0, 2);
    final minute = timeStr.substring(2, 4);
    return '$hour:$minute';
  }
}