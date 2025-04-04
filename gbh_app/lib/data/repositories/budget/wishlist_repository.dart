import 'package:marshmellow/data/datasources/remote/wishlist_api.dart';
import 'package:marshmellow/data/models/wishlist/wishlist_model.dart';

class WishlistRepository {
  final WishlistApi _wishlistApi;

  WishlistRepository(this._wishlistApi);

  // 위시리스트 생성
  Future<WishlistCreationResponse> createWishlist({
    required String productNickname,
    required String productName,
    required int productPrice,
    String? productImageUrl,
    String? productUrl,
  }) async {
    final response = await _wishlistApi.createWishlist(
      productNickname: productNickname,
      productName: productName,
      productPrice: productPrice,
      productImageUrl: productImageUrl,
      productUrl: productUrl,
    );

    final wishlistResponse = WishlistResponse.fromJson(response);

    if (wishlistResponse.code == 200) {
      return WishlistCreationResponse.fromJson(wishlistResponse.data);
    } else {
      throw Exception(wishlistResponse.message);
    }
  }

  // 위시리스트 조회
  Future<List<Wishlist>> getWishlists() async {
    final response = await _wishlistApi.getWishlists();
    final wishlistResponse = WishlistResponse.fromJson(response);

    if (wishlistResponse.code == 200) {
      final data = WishlistData.fromJson(wishlistResponse.data);
      return data.wishlist;
    } else {
      throw Exception(wishlistResponse.message);
    }
  }

  // 위시리스트 상세 조회
  Future<WishlistDetailResponse> getWishlistDetail(int wishlistPk) async {
    final response = await _wishlistApi.getWishlistDetail(wishlistPk);
    final wishlistResponse = WishlistResponse.fromJson(response);

    if (wishlistResponse.code == 200) {
      return WishlistDetailResponse.fromJson(wishlistResponse.data);
    } else {
      throw Exception(wishlistResponse.message);
    }
  }

  // 위시리스트 수정
  Future<WishlistUpdateResponse> updateWishlist({
    required int wishlistPk,
    String? productNickname,
    String? productName,
    int? productPrice,
    String? productImageUrl,
    String? productUrl,
    String? isSelected,     // 추가됨
    String? isCompleted,
    
  }) async {
    final response = await _wishlistApi.updateWishlist(
      wishlistPk: wishlistPk,
      productNickname: productNickname,
      productName: productName,
      productPrice: productPrice,
      productImageUrl: productImageUrl,
      productUrl: productUrl,
    );

    final wishlistResponse = WishlistResponse.fromJson(response);

    if (wishlistResponse.code == 200) {
      return WishlistUpdateResponse.fromJson(wishlistResponse.data);
    } else {
      throw Exception(wishlistResponse.message);
    }
  }

  // 위시리스트 삭제
  Future<WishlistDeleteResponse> deleteWishlist(int wishlistPk) async {
    final response = await _wishlistApi.deleteWishlist(wishlistPk);
    final wishlistResponse = WishlistResponse.fromJson(response);

    if (wishlistResponse.code == 200) {
      return WishlistDeleteResponse.fromJson(wishlistResponse.data);
    } else {
      throw Exception(wishlistResponse.message);
    }
  }
}