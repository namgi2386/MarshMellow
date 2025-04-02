import 'package:marshmellow/data/datasources/remote/api_client.dart';

class WishlistApi {
  final ApiClient _apiClient;
  
  WishlistApi(this._apiClient);

  // 위시리스트 생성
  Future<Map<String, dynamic>> createWishlist({
    required String productNickname,
    required String productName,
    required int productPrice,
    String? productImageUrl,
    String? productUrl,
  }) async {
    final data = {
      'productNickname': productNickname,
      'productName': productName,
      'productPrice': productPrice,
      'productImageUrl': productImageUrl,
      'productUrl': productUrl,
    };

    // null 값 가진 항목 제거
    data.removeWhere((key, value) => value == null);

    final response = await _apiClient.post('/api/mm/wishlist', data: data);
    return response;
  }

  // 위시 리스트 전체 조회
  Future<Map<String, dynamic>> getWishlists() async {
    final response = await _apiClient.get('/api/mm/wishlist');
    return response;
  }

  // 위시 리스트 상세 조회
  Future<Map<String, dynamic>> getWishlistDetail(int wishlistPk) async {
    final response = await _apiClient.get('/api/mm/wishlist/detail/$wishlistPk');
    return response;
  }
  
  // 위시 리스트 수정
  Future<Map<String, dynamic>> updateWishlist({
    required int wishlistPk,
    String? productNickname,
    String? productName,
    int? productPrice,
    String? productImageUrl,
    String? productUrl,
  }) async {
    final data = {
      'productNickname': productNickname,
      'productName': productName,
      'productPrice': productPrice,
      'productImageUrl': productImageUrl,
      'productUrl': productUrl,     
    };

    // null 값 가진 항목 제거 (업데이트하지 않을 필드)
    data.removeWhere((key, value) => value == null);

    final response = await _apiClient.put('/api/mm/wishlist/detail/$wishlistPk', data: data);
    return response;
  }

  // 위시리스트 삭제
  Future<Map<String, dynamic>> deleteWishlist(int wishlistPk) async {
    final response = await _apiClient.delete('/api/mm/wishlist/detail/$wishlistPk');
    return response;
  }
}

class WishApi {
  final ApiClient _apiClient;

  WishApi(this._apiClient);

  // 현재 진행중인 wish 조회
  Future<Map<String, dynamic>> getCurrentWish() async {
    final response = await _apiClient.get('/api/mm/wishlist/detail');
    return response;
  }

  // 특정 wish 상세 조회
  Future<Map<String, dynamic>> getWishDetail(int wishPk) async {
    final response = await _apiClient.get('/api/mm/wish/detail/$wishPk');
    return response;
  }
}