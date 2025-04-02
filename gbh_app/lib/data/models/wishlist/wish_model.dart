/*
  현재 진행 중인 wish API 모델
*/
class WishResponse {
  final int code;
  final String message;
  final dynamic data;

  WishResponse({
    required this.code,
    required this.message,
    required this.data
  });

  factory WishResponse.fromJson(Map<String, dynamic> json) {
    return WishResponse(
      code: json['code'], 
      message: json['message'], 
      data: json['data']
    );
  }
}

class WishDetail {
  final int wishlistPk;
  final String productNickname;
  final String productName;
  final int productPrice;
  final int achievePrice;
  final String? productImageUrl;
  final String? productUrl;
  final String isSelected;
  final String isCompleted;

  WishDetail({
    required this.wishlistPk,
    required this.productNickname,
    required this.productName,
    required this.productPrice,
    required this.achievePrice,
    this.productImageUrl,
    this.productUrl,
    required this.isSelected,
    required this.isCompleted,
  });

  factory WishDetail.fromJson(Map<String, dynamic> json) {
    return WishDetail(
      wishlistPk: json['wishlistPk'],
      productNickname: json['productNickname'],
      productName: json['productName'],
      productPrice: json['productPrice'],
      achievePrice: json['achievePrice'],
      productImageUrl: json['productImageUrl'],
      productUrl: json['productUrl'],
      isSelected: json['isSelected'],
      isCompleted: json['isCompleted'],
    );
  }

  // 달성률 계산을 위한 편의 메서드
  double get achievementRate => 
      productPrice > 0 ? (achievePrice / productPrice * 100) : 0;
      
  // 편의를 위한 copyWith 메서드
  WishDetail copyWith({
    int? wishlistPk,
    String? productNickname,
    String? productName,
    int? productPrice,
    int? achievePrice,
    String? productImageUrl,
    String? productUrl,
    String? isSelected,
    String? isCompleted,
  }) {
    return WishDetail(
      wishlistPk: wishlistPk ?? this.wishlistPk,
      productNickname: productNickname ?? this.productNickname,
      productName: productName ?? this.productName,
      productPrice: productPrice ?? this.productPrice,
      achievePrice: achievePrice ?? this.achievePrice,
      productImageUrl: productImageUrl ?? this.productImageUrl,
      productUrl: productUrl ?? this.productUrl,
      isSelected: isSelected ?? this.isSelected,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}