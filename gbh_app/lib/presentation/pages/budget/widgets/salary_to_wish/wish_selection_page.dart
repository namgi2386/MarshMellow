import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/data/models/wishlist/wishlist_model.dart';
import 'package:marshmellow/presentation/viewmodels/wishlist/wishlist_providers.dart';
import 'package:marshmellow/presentation/widgets/custom_appbar/custom_appbar.dart';
import 'package:marshmellow/presentation/widgets/loading/custom_loading_indicator.dart';
import 'package:marshmellow/presentation/widgets/modal/modal.dart';

/*
  예산 분배 완료 후, 
  이달의 위시를 설정하는 페이지 01
  : 위시리스트 목록으로부터 상품을 선택
*/
class WishSelectionPage extends ConsumerStatefulWidget{
  const WishSelectionPage({Key? key}) : super(key: key);

  @override
  _WishSelectionPageState createState() => _WishSelectionPageState();
}

class _WishSelectionPageState extends ConsumerState<WishSelectionPage> {

  @override
  void initState() {
    super.initState();
    // 위시리스트 목록 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(wishlistProvider.notifier).fetchWishlists();
    });
  }

  @override
  Widget build(BuildContext context) {
    final wishlistState = ref.watch(wishlistProvider);

    return Scaffold(
      appBar: CustomAppbar(
        title: '이달의 위시 선택',
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              '이번 달에 모을 위시를 선택해주세요',
              style: AppTextStyles.bodyLarge,
            ),
          ),
          if (wishlistState.isLoading)
            const Expanded(
              child: Center(
                child: CustomLoadingIndicator(
                  text: '위시리스트 목록 불러오는 중',
                ),
              ),
            )
          else if (wishlistState.errorMessage != null)
            Expanded(
              child: Center(
                child: Text(
                  wishlistState.errorMessage!,
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.red),
                ),
              ),
            )
          else if (wishlistState.wishlists.isEmpty)
            const Expanded(
              child: Center(
                child: Text('위시리스트가 비어있습니다. 먼저 위시리스트를 추가해주세요.'),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: wishlistState.wishlists.length,
                itemBuilder: (context, index) {
                  final wishlist = wishlistState.wishlists[index];
                  return _buildWishlistItem(wishlist);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWishlistItem(Wishlist wishlist) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showConfirmationModal(wishlist),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // 상품 이미지
              if (wishlist.productImageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    wishlist.productImageUrl!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: AppColors.modalBackground,
                        child: const Icon(Icons.image_not_supported),
                      );
                    },
                  ),
                )
              else
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.modalBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.shopping_bag),
                ),
              const SizedBox(width: 16),
              // 상품 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wishlist.productNickname,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      wishlist.productName,
                      style: AppTextStyles.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${wishlist.productPrice.toString().replaceAllMapped(
                            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                            (Match m) => '${m[1]},',
                          )} 원',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.blueDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmationModal(Wishlist wishlist) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Modal(
        backgroundColor: AppColors.modalBackground,
        title: '위시 등록',
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${wishlist.productNickname}을(를) 이달의 위시로 등록하시겠습니까?',
                style: AppTextStyles.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '등록 시 해당 상품을 위해 자동이체를 설정하게 됩니다.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.blueLight),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        '취소',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.blueLight,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.push('/wish/setup', extra: wishlist);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blueDark,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        '등록하기',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}