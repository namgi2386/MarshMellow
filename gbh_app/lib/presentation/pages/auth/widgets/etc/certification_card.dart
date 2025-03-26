import 'package:flutter/material.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';

/*
  금융인증서 카드
*/
class CertificateCard extends StatelessWidget {
  final String userName;
  final String expiryDate;
  final double width;
  final double height;
  final Color backgroundColor;
  final Color shieldColor;
  final Color textColor;
  final Color expiryLabelColor;
  final Color expiryLabelTextColor;
  final VoidCallback? onTap;

  const CertificateCard({
    Key? key,
    required this.userName,
    required this.expiryDate,
    this.width = 220,
    this.height = 140,
    this.backgroundColor = AppColors.yellowPrimary,
    this.shieldColor = AppColors.yellowLight,
    this.textColor = AppColors.backgroundBlack,
    this.expiryLabelColor = AppColors.whiteLight,
    this.expiryLabelTextColor = AppColors.backgroundBlack,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Text(
            'MM 인증서',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              // Shield BG
              Opacity(
                opacity: 0.3,
                child: Container(
                  width: width * 0.36,
                  height: width * 0.36,
                  decoration: BoxDecoration(
                    color: shieldColor,
                    shape: BoxShape.circle
                  ),
                ),
              ),
              // user icon
              Positioned(
                top: width * 0.05,
                child: Container(
                  width: width * 0.12,
                  height: width * 0.12,
                  decoration: const BoxDecoration(
                    color: AppColors.backgroundBlack,
                    shape: BoxShape.circle,
                  ),
                )
              )
            ],
          ),
          const SizedBox(height: 16),
          // Username
          Text(
            userName,
            style: AppTextStyles.bodyMedium,
          ),
          // Date
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                expiryDate,
                style: AppTextStyles.bodyMedium,
              ),
              Container(
                margin: EdgeInsets.only(left: 4),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: expiryLabelColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '만료',
                  style: AppTextStyles.bodySmall,
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

/*
  금융인증서 카드 ver.small
*/
class SmallCertificateCard extends StatelessWidget {
  final String userName;
  final String expiryDate;
  final Color backgroundColor;
  final Color shieldColor;
  final Color textColor;
  final Color expiryLabelColor;
  final Color expiryLabelTextColor;
  final VoidCallback? onTap;

  const SmallCertificateCard({
    Key? key,
    required this.userName,
    required this.expiryDate,
    this.backgroundColor = AppColors.yellowPrimary,
    this.shieldColor = AppColors.yellowLight,
    this.textColor = AppColors.backgroundBlack,
    this.expiryLabelColor = AppColors.whiteLight,
    this.expiryLabelTextColor = AppColors.backgroundBlack,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CertificateCard(
      userName: userName, 
      expiryDate: expiryDate,
      width: 180,
      height: 110,
      backgroundColor: backgroundColor,
      shieldColor: shieldColor,
      textColor: textColor,
      expiryLabelColor: expiryLabelColor,
      expiryLabelTextColor: expiryLabelTextColor,
      onTap: onTap,
    );
  }
} 