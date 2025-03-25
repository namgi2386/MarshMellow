// 카드 관련 모델
class CardData {
  final int totalAmount;
  final List<CardItem> cardList;

  CardData({
    required this.totalAmount,
    required this.cardList,
  });

  factory CardData.fromJson(Map<String, dynamic> json) {
    return CardData(
      totalAmount: json['totalAmount'],
      cardList: (json['cardList'] as List)
          .map((item) => CardItem.fromJson(item))
          .toList(),
    );
  }
}

class CardItem {
  final String cardNo;
  final String cvc;
  final String cardIssuerCode;
  final String cardIssuerName;
  final String cardName;
  final int cardBalance;

  CardItem({
    required this.cardNo,
    required this.cvc,
    required this.cardIssuerCode,
    required this.cardIssuerName,
    required this.cardName,
    required this.cardBalance,
  });

  factory CardItem.fromJson(Map<String, dynamic> json) {
    return CardItem(
      cardNo: json['cardNo'],
      cvc: json['cvc'],
      cardIssuerCode: json['cardIssuerCode'],
      cardIssuerName: json['cardIssuerName'],
      cardName: json['cardName'],
      cardBalance: json['cardBalance'],
    );
  }
}