// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:intl/intl.dart';
// import 'package:marshmellow/core/theme/app_colors.dart';
// import 'package:marshmellow/core/theme/app_text_styles.dart';
// import 'package:marshmellow/data/models/wishlist/wishlist_model.dart';
// import 'package:marshmellow/presentation/pages/budget/widgets/wish/wish_detail_modal.dart';
// import 'package:marshmellow/presentation/viewmodels/wishlist/wishlist_providers.dart';
// import 'package:marshmellow/presentation/widgets/completion_message/completion_message.dart';
// import 'package:marshmellow/presentation/widgets/modal/modal.dart';

// /// 위시 목록 탭 상태
// enum WishListTab {
//   pending,     // 대기중인 위시
//   inProgress,  // 진행중인 위시
//   completed,   // 완료된 위시
// }

// /*
//   위시 목록 모달 위젯
//   : 위시리스트를 대기/진행중/완료 탭으로 분류하며 각 항목 선택시 상세보기가능
// */
// class WishListModal extends ConsumerStatefulWidget {
//   final WishListTab initialTab;

//   const WishListModal({
//     Key? key,
//     this.initialTab = WishListTab.inProgress
//   }) : super(key: key);

//   @override
//   ConsumerState<WishListModal> createState() => _WishListModalState();
// }

// class _WishListModalState extends ConsumerState<WishListModal> with SingleTickerProviderStateMixin {
//   late WishListTab _selectedTab;

//   @override
//   void initState() {
//     super.initState();
//     _selectedTab = widget.initialTab;

//     // 위시리스트 불러오기
//     Future.microtask(() {
//       ref.read(wishlistProvider.notifier).fetchWishlists();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final wishliststate = ref.watch(wishlistProvider);

//     // 로딩중이면 로딩인디케이터
//     if (wishliststate.isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     // 필터링된 위시리스트
//     final pendingWishes = wishliststate.wishlists
//         .where((wish) => wish.isSelected == 'N' && wish.isCompleted == 'N')
//         .toList();

//     final inProgressWishes = wishliststate.wishlists
//         .where((wish) => wish.isSelected == 'Y' && wish.isCompleted == 'N')
//         .toList();
    
//     final completedWishes = wishliststate.wishlists
//         .where((wish) => wish.isCompleted == 'Y')
//         .toList();

//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         // 탭선택기
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 8),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               _buildTabButton(WishListTab.pending, '대기', pendingWishes.length),
//               _buildTabButton(WishListTab.inProgress, '진행중', inProgressWishes.length),
//               _buildTabButton(WishListTab.completed, '완료', completedWishes.length),
//             ],
//           ),
//         ),

//         const Divider(height: 1),

//         // 위시 목록
//         SizedBox(
//           height: MediaQuery.of(context).size.height * 0.5,
//           child: _buildWishList(_selectedTab),
//         ),

//         // + 추가하기 버튼(완료 탭 아닐 때만 표시)
//         if (_selectedTab == WishListTab.pending)
//           Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: InkWell(
//             onTap: () {
//               // 위시 추가 페이지 이동 (구현 필요)
//               Navigator.of(context).pop();
//               Navigator.of(context).pushNamed('/wish/add');
//             },
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.add_circle_outline, 
//                   color: AppColors.bluePrimary,
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   '추가하기',
//                   style: TextStyle(
//                     color: AppColors.bluePrimary,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // 탭버튼 위젯
//   Widget _buildTabButton(WishListTab tab, String title, int count) {
//     final isSelected = _selectedTab == tab;

//     return Expanded(
//       child: InkWell(
//         onTap: () {
//           setState(() {
//             _selectedTab = tab;
//           });
//         },
//         child: Container(
//           decoration: BoxDecoration(
//             color: isSelected ? AppColors.bluePrimary.withOpacity(0.2) : Colors.transparent,
//             borderRadius: BorderRadius.circular(20),
//           ),
//           padding: const EdgeInsets.symmetric(vertical: 10),
//           child: Column(
//             children: [
//               Text(
//                 title,
//                 style: TextStyle(
//                   color: isSelected ? AppColors.textPrimary : AppColors.textPrimary.withOpacity(0.2),
//                   fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                 ),
//               ),
//               if (count > 0)
//                 Container(
//                   margin: const EdgeInsets.only(top: 4),
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                   decoration: BoxDecoration(
//                     color: isSelected ? AppColors.bluePrimary : AppColors.disabled,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Text(
//                     count.toString(),
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // 위시 목록 위젯
//   Widget _buildWishList(WishListTab tab) {
//     final wishlistState = ref.watch(wishlistProvider);

//     List<Wishlist> filteredWishes;

//     switch (tab) {
//       case WishListTab.pending:
//         filteredWishes = wishlistState.wishlists
//             .where((wish) => wish.isSelected == 'N' && wish.isCompleted == 'N')
//             .toList();
//         break;
//       case WishListTab.inProgress:
//         filteredWishes = wishlistState.wishlists
//             .where((wish) => wish.isSelected == 'Y' && wish.isCompleted == 'N')
//             .toList();
//         break;
//       case WishListTab.completed:
//         filteredWishes = wishlistState.wishlists
//             .where((wish) => wish.isCompleted == 'Y')
//             .toList();
//         break;
//     }

//     if (filteredWishes.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.sentiment_neutral,
//               size: 60,
//               color: AppColors.disabled,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               _getEmptyMessage(tab),
//               style: TextStyle(color: AppColors.disabled),
//             ),
//           ],
//         ),
//       );
//     }

//     return ListView.separated(
//       itemCount: filteredWishes.length,
//       separatorBuilder: (context, index) => const Divider(height: 1),
//       itemBuilder: (context, index) {
//         final wish = filteredWishes[index];

//         // 완료탭이면 슬라이더블(스와이프삭제) 추가
//         if (tab == WishListTab.completed) {
//           return _buildCompletedWishItem(wish);
//         } else {
//           return _buildWishItem(wish);
//         }
//       },
//     );
//   }

//   // 위시 아이템
//   Widget _buildWishItem(Wishlist wish) {
//     // 가격 포맷팅
//     final formatter = NumberFormat('#,###');
//     final formattedPrice = formatter.format(wish.productPrice);
    
//     // 이미지 URL 처리
//     String? imageUrl;
//     if (wish.productImageUrl != null && wish.productImageUrl!.isNotEmpty) {
//       if (wish.productImageUrl!.startsWith('//')) {
//         imageUrl = 'https:${wish.productImageUrl!}';
//       } else if (!wish.productImageUrl!.startsWith('file://')) {
//         imageUrl = wish.productImageUrl;
//       }
//     }

//     return InkWell(
//       onTap: () {
//         // 현재 모달 닫기
//         Navigator.of(context).pop();
        
//         // 상세 모달 열기
//         showCustomModal(
//           context: context,
//           ref: ref,
//           backgroundColor: Colors.white,
//           title: '위시 상세',
//           child: WishDetailModal(wishPk: wish.wishlistPk),
//         );
//       },
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         child: Row(
//           children: [
//             // 이미지
//             ClipRRect(
//               borderRadius: BorderRadius.circular(25),
//               child: SizedBox(
//                 width: 50,
//                 height: 50,
//                 child: imageUrl != null
//                     ? Image.network(
//                         imageUrl,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) {
//                           return Container(
//                             color: AppColors.whiteDark,
//                             child: const Icon(Icons.image_not_supported, color: Colors.grey),
//                           );
//                         },
//                       )
//                     : Container(
//                         color: AppColors.whiteDark,
//                         child: const Icon(Icons.image_not_supported, color: Colors.grey),
//                       ),
//               ),
//             ),
//             const SizedBox(width: 16),
            
//             // 정보
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     wish.productNickname,
//                     style: AppTextStyles.bodyMedium,
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     wish.productName,
//                     style: AppTextStyles.bodyExtraSmall.copyWith(color: AppColors.textSecondary),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ),
//             ),
            
//             // 가격
//             Text(
//               '$formattedPrice 원',
//               style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // 완료된 위시 아이템(슬라이더블)
//   Widget _buildCompletedWishItem(Wishlist wish) {
//     return Slidable(
//       endActionPane: ActionPane(
//         motion: const ScrollMotion(), 
//         children: [
//           SlidableAction(
//             onPressed: (context) => _deleteWish(wish.wishlistPk),
//             backgroundColor: Colors.red,
//             foregroundColor: Colors.white,
//             icon: Icons.delete,
//             label: '삭제',
//           )
//         ]
//       ),
//       child: _buildWishItem(wish),
//     );
//   }

//   // 위시 삭제 처리
//   void _deleteWish(int wishPk) async {
//     try {
//       await ref.read(wishlistProvider.notifier).deleteWishlist(wishPk);
      
//       if (mounted) {
//         CompletionMessage.show(context, message: '위시가 삭제되었습니다.');
//       }
//     } catch (e) {
//       if (mounted) {
//         CompletionMessage.show(context, message: '위시 삭제 중 오류가 발생했습니다.');
//       }
//     }
//   }

//   // 빈 목록 메시지
//   String _getEmptyMessage(WishListTab tab) {
//     switch (tab) {
//       case WishListTab.pending:
//         return '대기중인 위시가 없습니다';
//       case WishListTab.inProgress:
//         return '진행중인 위시가 없습니다';
//       case WishListTab.completed:
//         return '완료된 위시가 없습니다';
//     }
//   }
// }
