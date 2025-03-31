import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CardImageUtil {
  // 카드 데이터 하드코딩
// 카드 데이터 하드코딩
  static final List<Map<String, String>> cardDataList = [
    {
      "cardUniqueNo": "1001-ebaf3e5cd45b4ba",
      "cardName": "KB국민 My WE:SH 카드",
      "imgCode": "1001-1.png"
    },
    {
      "cardUniqueNo": "1001-cac82fb31bc9461",
      "cardName": "SSAFY 스마일카드",
      "imgCode": "1001-2.png"
    },
    {
      "cardUniqueNo": "1002-127a04fd142a480",
      "cardName": "taptap DIGITAL",
      "imgCode": "1002-1.png"
    },
    {
      "cardUniqueNo": "1002-fc040c6c89eb43a",
      "cardName": "삼성 iD CLASSY 카드",
      "imgCode": "1002-2.png"
    },
    {
      "cardUniqueNo": "1003-fefca83172f64d4",
      "cardName": "LOCA 365 카드",
      "imgCode": "1003-1.png"
    },
    {
      "cardUniqueNo": "1003-c8c626c0d828439",
      "cardName": "디지로카 London",
      "imgCode": "1003-2.png"
    },
    {
      "cardUniqueNo": "1004-a47dbe1629344b9",
      "cardName": "DA카드의정석 II",
      "imgCode": "1004-1.png"
    },
    {
      "cardUniqueNo": "1004-0bd60e56bb284ee",
      "cardName": "카드의정석 EVERY 1",
      "imgCode": "1004-2.png"
    },
    {
      "cardUniqueNo": "1005-049db4fd983c465",
      "cardName": "신한카드 YaY",
      "imgCode": "1005-1.gif"
    },
    {
      "cardUniqueNo": "1005-6747061c79c7448",
      "cardName": "신한카드 Edu Plan+",
      "imgCode": "1005-2.gif"
    },
    {
      "cardUniqueNo": "1006-7a7c7d3328f943e",
      "cardName": "현대카드 M",
      "imgCode": "1006-1.png"
    },
    {
      "cardUniqueNo": "1006-09b3806001344c3",
      "cardName": "American Express",
      "imgCode": "1006-2.png"
    },
    {
      "cardUniqueNo": "1007-83dd60116c02441",
      "cardName": "BC 바로 KaPick",
      "imgCode": "1007-1.png"
    },
    {
      "cardUniqueNo": "1007-d9f92978b7784b2",
      "cardName": "BC 바로 클리어 플러스",
      "imgCode": "1007-2.png"
    },
    {
      "cardUniqueNo": "1008-eed40b4ba0a94fb",
      "cardName": "올바른 FLEX 카드",
      "imgCode": "1008-1.png"
    },
    {
      "cardUniqueNo": "1008-c4d9dbfc67ba4dd",
      "cardName": "별다줄카드",
      "imgCode": "1008-2.png"
    },
    {
      "cardUniqueNo": "1009-6ac70cb1e8c6405",
      "cardName": "CLUB SK 카드",
      "imgCode": "1009-1.png"
    },
    {
      "cardUniqueNo": "1009-abe5b7d5ca5d4fc",
      "cardName": "트래블로그 신용카드",
      "imgCode": "1009-2.png"
    },
    {
      "cardUniqueNo": "1010-4501470483b3416",
      "cardName": "I-Mileage (아시아나)",
      "imgCode": "1010-1.png"
    },
    {
      "cardUniqueNo": "1010-f32dca83fc0b429",
      "cardName": "I-Mileage (대한항공)",
      "imgCode": "1010-2.png"
    }
  ];


  // 카드 이름으로 이미지 코드 찾는 함수
  static String getCardImageCode(String cardName) {
    final cardData = cardDataList.firstWhere(
      (card) => card["cardName"] == cardName,
      orElse: () => {"imgCode": "testCard.svg"},
    );
    
    return cardData["imgCode"] ?? "testCard.svg";
  }

  // 이미지 위젯 만드는 함수
  static Widget getCardImageWidget(String cardName, {double size = 64}) {
    final imgCode = getCardImageCode(cardName);
    final imgPath = 'assets/icons/card/$imgCode';
    
    if (imgCode.endsWith('.svg')) {
      return SvgPicture.asset(
        imgPath,
        width: size,
        height: size,
      );
    } else {
      return Image.asset(
        imgPath,
        width: size,
        height: size,
      );
    }
  }
}