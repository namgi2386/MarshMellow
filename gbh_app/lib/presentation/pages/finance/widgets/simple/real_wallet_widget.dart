import 'package:flutter/material.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/core/constants/icon_path.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:marshmellow/presentation/widgets/finance/card_image_util.dart';

// 은행별 카드 색상 매핑
class BankColors {
  static final Map<String, Color> colors = {
    '신한은행': const Color(0xFF1478FF),
    '국민은행': const Color(0xFF29AB87),
    '우리은행': const Color(0xFF005BAC),
    '하나은행': const Color(0xFF008485),
    '농협은행': const Color(0xFF0091D0),
    '기업은행': const Color(0xFF0061A5),
    '국민은행': const Color(0xFF29AB87),
    '카카오뱅크': const Color(0xFFFFDE00),
    '토스뱅크': const Color(0xFF0064FF),
    '케이뱅크': const Color(0xFFEC0000),
    '한국은행': const Color.fromARGB(255, 131, 171, 217),     // 한국은행 파란색
    '산업은행': const Color(0xFF00A0E2),     // 산업은행 청색
    '농협은행': const Color(0xFF0091D0),     // 농협은행 청색
    'sc제일은행': const Color(0xFF00A650),   // SC제일은행 녹색
    '시티은행': const Color(0xFF0066B3),     // 시티은행 파란색
    '대구은행': const Color(0xFF0072BC),     // 대구은행 파란색
    '광주은행': const Color(0xFF0066B3),     // 광주은행 파란색
    '제주은행': const Color(0xFF00A651),     // 제주은행 녹색
    '전북은행': const Color(0xFF00338D),     // 전북은행 진청색
    '경남은행': const Color(0xFF005E35),     // 경남은행 녹색
    '새마을금고': const Color(0xFF019E4A),   // 새마을금고 녹색
    '싸피뱅크': const Color(0xFF1EC800),     // 임의 색상
    // 기본값
    'default': AppColors.pinkPrimary,
  };
  
  static Color getColorByBankName(String bankName) {
    return colors[bankName] ?? colors['default']!;
  }
}

// 계좌 정보 모델 (클래스 이름을 DemandDepositItem으로 변경)
// 클래스 이름만 변경하고 내부 필드는 그대로 유지
class DemandDepositItem {
  final String bankName;
  final String accountName;
  final String accountNo;
  final int accountBalance;
  
  DemandDepositItem({
    required this.bankName,
    required this.accountName,
    required this.accountNo,
    required this.accountBalance,
  });
}

// 앞서 만든 CardInfo 클래스
class CardInfo {
  final String cardName;
  final Color cardColor;
  final String? cardNumber;
  
  CardInfo({
    required this.cardName,
    required this.cardColor,
    this.cardNumber,
  });
}

// 계좌 정보를 CardInfo로 변환하는 함수 (DemandDepositItem으로 파라미터 타입 변경)
List<CardInfo> convertToCardInfoList(List<DemandDepositItem> accounts) {
  // 입출금 계좌가 없거나 1개만 있는 경우 처리
  if (accounts.isEmpty) {
    return [
      CardInfo(cardName: '계좌 없음', cardColor: Colors.white, cardNumber: null),
      CardInfo(cardName: '계좌 없음', cardColor: Colors.white, cardNumber: null),
    ];
  } else if (accounts.length == 1) {
    // 계좌가 1개인 경우, 하나는 실제 계좌, 하나는 빈 계좌
    return [
      CardInfo(
        cardName: accounts[0].bankName,
        cardColor: BankColors.getColorByBankName(accounts[0].bankName),
        cardNumber: accounts[0].accountNo.substring(max(0, accounts[0].accountNo.length - 4)),
      ),
      CardInfo(cardName: '계좌 없음', cardColor: Colors.white, cardNumber: null),
    ];
  } else {
    // 계좌가 2개 이상인 경우, 첫 2개만 사용
    return accounts.take(2).map((account) => CardInfo(
      cardName: account.bankName,
      cardColor: BankColors.getColorByBankName(account.bankName),
      cardNumber: account.accountNo.substring(max(0, account.accountNo.length - 4)),
    )).toList();
  }
}

// 최솟값 반환 함수
int max(int a, int b) {
  return a > b ? a : b;
}

// 월렛 위젯 구현
class DefaultWalletWidget extends StatelessWidget {
  final List<CardInfo> cards;
  final String accountType;
  final int balance;

  bool _isPngPath(String path) {
    return path.endsWith('.png');
  }
  // 은행 이름에 따라 아이콘 경로를 반환하는 메서드
  String _getBankIconPath(String bankName) {
    switch (bankName.toLowerCase()) {
      case "한국은행":
      case "korea bank":
        return IconPath.koreaBank2;
      case "산업은행":
      case "kdb bank":
        return IconPath.kdbBank;
      case "기업은행":
      case "ibk bank":
        return IconPath.ibkBank;
      case "국민은행":
      case "kb bank":
        return IconPath.kbBank;
      case "농협은행":
      case "nh bank":
        return IconPath.nhBank;
      case "우리은행":
      case "woori bank":
        return IconPath.wooriBank;
      case "sc제일은행":
      case "standard chartered bank":
      case "sc bank":
        return IconPath.scBank;
      case "시티은행":
      case "citi bank":
        return IconPath.citiBank;
      case "대구은행":
      case "daegu bank":
        return IconPath.dgBank;
      case "광주은행":
      case "gwangju bank":
        return IconPath.gjBank;
      case "제주은행":
      case "jeju bank":
        return IconPath.jejuBank;
      case "전북은행":
      case "jeonbuk bank":
        return IconPath.jbBank;
      case "경남은행":
      case "gyeongnam bank":
        return IconPath.gnBank;
      case "새마을금고":
      case "mg":
        return IconPath.mgBank;
      case "하나은행":
      case "hana bank":
        return IconPath.hanaBank;
      case "신한은행":
      case "shinhan bank":
        return IconPath.shinhanBank;
      case "카카오뱅크":
      case "kakao bank":
        return IconPath.kakaoBank;
      case "싸피뱅크":
      case "ssafy bank":
      case "toss bank":
        return IconPath.ssafyBank2;
      default:
        // return IconPath.plus; // 기본값으로 IBK 아이콘 사용
        return IconPath.testCard;
    }
  }
  Widget _buildBankIcon(String bankName) {
    final String iconPath = _getBankIconPath(bankName);

    if (_isPngPath(iconPath)) {
      return Image.asset(
        iconPath,
        width: 40, // 원하는 크기로 조정
        height: 40,
      );
    } else {
      return SvgPicture.asset(
        iconPath,
        width: 40, // 원하는 크기로 조정
        height: 40,
      );
    }
  }
  
  const DefaultWalletWidget({
    Key? key,
    required this.cards,
    required this.accountType,
    required this.balance,
  }) : assert(cards.length == 2, '카드는 정확히 2개가 필요합니다'),
      super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      height: MediaQuery.of(context).size.width * 0.4,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          // 카드 2장
          Container(
            child: Stack(
              alignment: Alignment.center,
              children: [
                _buildStackedCards(context),
              ],
            ),
          ),
          const SizedBox(height: 30.0),
          // 하단 검은색 영역 (계좌 정보)
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    accountType,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.whiteLight)
                  ),
                  if (balance != -1)
                  Text(
                    '${_formatCurrency(balance)}원',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.whiteLight)
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStackedCards(context) {
    double parentWidth = MediaQuery.of(context).size.width * 0.4;
    return Stack(
      alignment: Alignment.center,
      
      children: [
        // 첫 번째 카드 (뒤에 있는 카드)
        Transform.translate(
          offset: const Offset(0, 10),
          child: _buildCard(cards[0], isFirst: true, parentWidth: parentWidth),
        ),
        
        // 두 번째 카드 (앞에 있는 카드)
        Transform.translate(
          offset: const Offset(0, 40),
          child: _buildCard(cards[1], isFirst: false, parentWidth: parentWidth),
        ),
        Transform.translate(
          offset: const Offset(0, 55),
          child: CustomShapeBox(
            width: parentWidth * 0.65,
            height: parentWidth * 0.25,
            color: AppColors.blackDark
          ),
        ),
      ],
    );
  }
  
  Widget _buildCard(CardInfo card, {required bool isFirst, required double parentWidth}) {
    return Container(
      width: parentWidth * 0.85,
      height: parentWidth * 0.25,
      decoration: BoxDecoration(
        color: card.cardColor,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0),topRight: Radius.circular(10.0) ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.8),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 0.0),
    child: card.cardName == "계좌 없음"
        ? Center(
            child: IconButton(
              icon: SvgPicture.asset(IconPath.plus,
              colorFilter: ColorFilter.mode(AppColors.blackLight, BlendMode.srcIn),),
              onPressed: () {
                // _onAccountItemTap(context);
              },
            ),
          )
        : accountType == "대출"
            ? Container(
                padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
                alignment: Alignment.topCenter,
                child: Text(
                  card.cardName,
                  style: AppTextStyles.bodySmall,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              )
            : accountType == "카드" ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: CardImageUtil.getCardImageWidget(card.cardName, size: 64),
                    onPressed: () {
                      // _onAccountItemTap(context);
                    },
                  ),
                  Expanded(  // 여기가 중요한 변경점입니다
                    child: Container(
                      alignment: Alignment.topCenter,
                      padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
                      child: Text(
                        card.cardName,
                        style: AppTextStyles.bodySmall,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ],
              ) : Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: _buildBankIcon(card.cardName),
                    onPressed: () {
                      // _onAccountItemTap(context);
                    },
                  ),
                  Expanded(  // 여기가 중요한 변경점입니다
                    child: Container(
                      alignment: Alignment.topCenter,
                      padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
                      child: Text(
                        card.cardName,
                        style: AppTextStyles.bodySmall,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ],
              )
    );
  }
  
  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}

// 기존 코드를 대체할 위젯 (DemandDepositItem으로 파라미터 타입 변경)
class RealWallet extends StatelessWidget {
  final List<DemandDepositItem> demandDepositList;
  final int totalAmount;
  final String type;
  
  const RealWallet({
    Key? key, 
    required this.demandDepositList, 
    required this.totalAmount,
    required this.type
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // 계좌 정보를 CardInfo로 변환
    final List<CardInfo> cardInfoList = convertToCardInfoList(demandDepositList);
    
    // Wallet 위젯 반환
    return DefaultWalletWidget(
      cards: cardInfoList,
      accountType: type,
      balance: totalAmount,
    );
  }
} 

// <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
class CustomShapeBox extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  const CustomShapeBox({
    Key? key,
    required this.width,
    required this.height,
    required this.color,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: BoxClipper(),
      child: Container(
        width: width,
        height: height,
        color: color,
      ),
    );
  }
}
class BoxClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    
    // 곡선 깊이 조절 (값을 조절하여 곡선의 정도를 바꿀 수 있습니다)
    final curveHeight = size.height * 0.35;
    
    // 시작점 (왼쪽 하단)
    path.moveTo(0, size.height);
    
    // 왼쪽 상단 곡선
    path.quadraticBezierTo(0, curveHeight, curveHeight, curveHeight);
    
    // 상단 직선
    path.lineTo(size.width - curveHeight, curveHeight);
    
    // 오른쪽 상단 곡선
    path.quadraticBezierTo(size.width, curveHeight, size.width, size.height);
    
    // 완성
    path.close();
    
    return path;
  }
  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}