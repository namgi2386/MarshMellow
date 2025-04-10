import 'package:flutter/material.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/data/models/my/salary_model.dart';

class AccountSelectionSection extends StatelessWidget {
  final List<AccountModel> accounts;
  final AccountModel? selectedAccount;
  final Function(AccountModel) onAccountSelected;
  final bool isLoading;
  final String? errorMessage;

  const AccountSelectionSection({
    Key? key,
    required this.accounts,
    required this.selectedAccount,
    required this.onAccountSelected,
    this.isLoading = false,
    this.errorMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 로딩 표시
        if (isLoading)
          const Center(
            child: CircularProgressIndicator(),
          )
        // 오류 메시지 표시
        else if (errorMessage != null)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  errorMessage!,
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // 재시도 로직
                  },
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          )
        // 계좌 목록이 비어있을 때
        else if (accounts.isEmpty)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppColors.textSecondary,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  '계좌 정보가 없습니다.',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          )
        // 계좌 목록 표시
        else
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: accounts.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final account = accounts[index];
              final isSelected = selectedAccount?.accountNo == account.accountNo;

              return _buildAccountItem(account, isSelected);
            },
          ),
      ],
    );
  }

  Widget _buildAccountItem(AccountModel account, bool isSelected) {
    return InkWell(
      onTap: () => onAccountSelected(account),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
        child: Row(
          children: [
            // 은행 로고 또는 아이콘 (실제 프로젝트에서는 은행별 로고 이미지 사용)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  account.bankName.substring(0, 1),
                  style: AppTextStyles.bodyLarge,
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // 계좌 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.bankName,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatAccountNumber(account.accountNo),
                    style: AppTextStyles.bodyMedium,
                  ),
                  if (account.accountName.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      account.accountName,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // 선택 표시
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.backgroundBlack,
                size: 24,
              )
            else
              const Icon(
                Icons.circle_outlined,
                color: AppColors.textSecondary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  // 계좌번호 포맷팅 (예: 1234-5678-9012 -> 1234-****-9012)
  String _formatAccountNumber(String accountNo) {
    if (accountNo.length < 8) return accountNo;
    
    // 실제 앱에서는 '-' 처리 등 더 복잡한 로직이 있을 수 있습니다.
    // 간단한 예시만 구현합니다.
    final firstPart = accountNo.substring(0, 4);
    final lastPart = accountNo.substring(accountNo.length - 4);
    
    return '$firstPart-****-$lastPart';
  }
}