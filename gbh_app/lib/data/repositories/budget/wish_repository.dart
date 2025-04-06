import 'package:marshmellow/data/datasources/remote/budget/wishlist_api.dart';
import 'package:marshmellow/data/models/wishlist/wish_model.dart';

class WishRepository {
  final WishApi _wishApi;

  WishRepository(this._wishApi);

  // 현재 진행 중인 wish 조회
  Future<WishDetail?> getCurrentWish() async {
    try {
      print('Repository: Fetching current wish...');
      final response = await _wishApi.getCurrentWish();
      final wishResponse = WishResponse.fromJson(response);

      if (wishResponse.code == 200 && wishResponse.data != null) {
        return WishDetail.fromJson(wishResponse.data);
      } else {
        // 404 등 정상 응답이지만 데이터 없는 경우
        print('Repository: No wish data found or non-200 code');
        return null;
      }
    } catch (e) {
      throw Exception('현재 진행 중인 wish를 불러오는 중 오류가 발생했습니다: $e');
    }
  }
}