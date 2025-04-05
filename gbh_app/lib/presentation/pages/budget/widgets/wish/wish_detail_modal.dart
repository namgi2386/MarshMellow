import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:marshmellow/router/routes/budget_routes.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/data/models/wishlist/wish_model.dart';
import 'package:marshmellow/data/models/wishlist/wishlist_model.dart';
import 'package:marshmellow/presentation/viewmodels/wishlist/wish_provider.dart';
import 'package:marshmellow/presentation/viewmodels/wishlist/wishlist_providers.dart';
import 'package:marshmellow/presentation/widgets/button/button.dart';
import 'package:marshmellow/presentation/widgets/completion_message/completion_message.dart';
import 'package:marshmellow/presentation/widgets/round_input/round_input.dart';

/// 위시 목록 탭 상태
enum WishListTab {
  pending,     // 대기중인 위시
  inProgress,  // 진행중인 위시
  completed,   // 완료된 위시
}

/*
  위시 상세 조회 모달 위젯
  : 선택한 위시의 상세 내역을 보여주며 수정/삭제 기능을 제공
*/
class WishDetailModal extends ConsumerStatefulWidget {
  final int? wishPk;
  final WishDetail? currentWish;
  final WishListTab initialTab;

  const WishDetailModal({
    Key? key,
    this.wishPk,
    this.currentWish,
    this.initialTab = WishListTab.inProgress,
  }) : super(key: key);

  @override
  ConsumerState<WishDetailModal> createState() => _WishDetailModalState();
}

class _WishDetailModalState extends ConsumerState<WishDetailModal> {
  final _formkey = GlobalKey<FormState>();
  late TextEditingController _nicknameController;
  late TextEditingController _productNameController;
  late TextEditingController _priceController;
  late TextEditingController _urlController;
  
  // 각 필드별 편집 상태를 추적
  bool _isEditingNickname = false;
  bool _isEditingProductName = false;
  bool _isEditingPrice = false;
  bool _isEditingUrl = false;
  
  // 현재 선택된 탭
  late WishListTab _selectedTab;
  
  // 현재 선택된 위시 아이템 (상세 보기 모드에서 사용)
  int? _selectedWishPk;
  WishDetail? _selectedWish;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
    _selectedWishPk = widget.wishPk;
    _selectedWish = widget.currentWish;
    _initializeControllers();

    // 위시 상세 정보 로드
    if (_selectedWishPk != null) {
    Future.microtask(() {
      ref.read(wishlistProvider.notifier).fetchWishlistDetail(_selectedWishPk!);  
    });
  }
 
    // 위시리스트 불러오기
    Future.microtask(() {
      ref.read(wishlistProvider.notifier).fetchWishlists();
    });

    // 위시(진행중) 불러오기
    Future.microtask(() {
      ref.read(wishProvider.notifier).fetchCurrentWish();
    });
  }

  void _initializeControllers() {
    final wish = _selectedWish;
    _nicknameController = TextEditingController(text: wish?.productNickname ?? '');
    _productNameController = TextEditingController(text: wish?.productName ?? '');
    _priceController = TextEditingController(
      text: wish?.productPrice != null
        ? NumberFormat('#,###').format(wish!.productPrice)
        : ''
    );
    _urlController = TextEditingController(text: wish?.productUrl ?? '');
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _productNameController.dispose();
    _priceController.dispose();
    _urlController.dispose();
    super.dispose();
  }
  
  // URL 열기 함수
  Future<void> _launchURL(String url) async {
    if (url.isEmpty) return;
    
    // URL에 프로토콜이 없으면 추가
    String launchUrl = url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      launchUrl = 'https://$url';
    }
    
    try {
      await launch(launchUrl);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('URL을 열 수 없습니다: $launchUrl')),
        );
      }
    }
  }

  // 탭 변경 처리
  void _changeTab(WishListTab tab) {
    if (_selectedTab == tab) return; // 이미 선택된 탭이면 무시
    
    // 편집 중인 필드가 있는지 확인
    bool isEditing = _isEditingNickname || _isEditingProductName || 
                     _isEditingPrice || _isEditingUrl;
    
    if (isEditing) {
      // 편집 중인 경우 확인 다이얼로그 표시
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('편집 취소'),
          content: const Text('변경 사항이 저장되지 않습니다. 계속하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('아니오'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('예'),
            ),
          ],
        ),
      ).then((confirmed) {
        if (confirmed == true) {
          setState(() {
            _selectedTab = tab;
            _selectedWishPk = null;
            _selectedWish = null;
            _resetEditingState();
          });
        }
      });
    } else {
      setState(() {
        _selectedTab = tab;
        _selectedWishPk = null;
        _selectedWish = null;
        _resetEditingState();
      });
    }
  }
  
  // 편집 상태 초기화
  void _resetEditingState() {
    _isEditingNickname = false;
    _isEditingProductName = false;
    _isEditingPrice = false;
    _isEditingUrl = false;
  }
  
  // 위시 선택 처리
  void _selectWish(int wishPk) {
    setState(() {
      _selectedWishPk = wishPk;
      _selectedWish = null; // 상세 정보 초기화 (로드 필요)
      _resetEditingState();
    });
    
    // 위시 상세 정보 로드
    ref.read(wishlistProvider.notifier).fetchWishlistDetail(wishPk);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formkey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 탭 영역
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTabButton(WishListTab.pending, '대기'),
                _buildTabButton(WishListTab.inProgress, '진행중'),
                _buildTabButton(WishListTab.completed, '완료'),
              ],
            ),
          ),
          
          // 디바이더
          // const Divider(height: 1, thickness: 1),
          
          // 컨텐츠 영역 - 선택된 탭에 따라 다른 내용 표시
          _selectedWishPk != null 
            ? _buildWishDetailContent() // 위시 상세 내용
            : _buildWishListContent(), // 위시 목록
        ],
      ),
    );
  }
  
  // 탭 버튼 위젯
  Widget _buildTabButton(WishListTab tab, String title) {
    final isSelected = _selectedTab == tab;

    return Expanded(
      child: InkWell(
        onTap: () => _changeTab(tab),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.backgroundBlack : Colors.transparent,
            borderRadius: BorderRadius.circular(40),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? AppColors.whiteLight : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w200 : FontWeight.w200,
            ),
          ),
        ),
      ),
    );
  }
  
  // 위시 목록 컨텐츠
  Widget _buildWishListContent() {
    final wishlistState = ref.watch(wishlistProvider);
    
    // 로딩 중이면 로딩 인디케이터
    if (wishlistState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    // 필터링된 위시리스트
    List<Wishlist> filteredWishes;
    
    switch (_selectedTab) {
      case WishListTab.pending:
        filteredWishes = wishlistState.wishlists
            .where((wish) => wish.isSelected == 'N' && wish.isCompleted == 'N')
            .toList();
        break;
      case WishListTab.inProgress:
        filteredWishes = wishlistState.wishlists
            .where((wish) => wish.isSelected == 'Y' && wish.isCompleted == 'N')
            .toList();
        break;
      case WishListTab.completed:
        filteredWishes = wishlistState.wishlists
            .where((wish) => wish.isCompleted == 'Y')
            .toList();
        break;
    }
    
    // 위시 목록이 비어있는 경우
    if (filteredWishes.isEmpty) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                _getEmptyImage(_selectedTab),
                height: 150,
              ),
              const SizedBox(height: 16),
              Text(
                _getEmptyMessage(_selectedTab),
                style: TextStyle(color: AppColors.disabled),
              ),
            ],
          ),
        ),
      );
    }
    
    // 위시 목록 표시
    return Column(
      children: [
        const SizedBox(height: 20),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
          child: ListView.separated(
            itemCount: filteredWishes.length,
            separatorBuilder: (context, index) => const Divider(thickness: 0.5),
            itemBuilder: (context, index) {
              final wish = filteredWishes[index];
              return _buildWishItem(wish);
            },
          ),
        ),
        
        // + 추가하기 버튼(대기 탭일 때만 표시)
        if (_selectedTab == WishListTab.pending)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop();
                context.go(BudgetRoutes.getWishlistCreatePath());
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_circle_outline, 
                    color: AppColors.greyLight,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '추가하기',
                    style: TextStyle(
                      color: AppColors.backgroundBlack,
                      fontWeight: FontWeight.w200,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
  
  // 위시 아이템 위젯
  Widget _buildWishItem(Wishlist wish) {
    // 가격 포맷팅
    final formatter = NumberFormat('#,###');
    final formattedPrice = formatter.format(wish.productPrice);
    
    // 이미지 URL 처리
    String? imageUrl;
    if (wish.productImageUrl != null && wish.productImageUrl!.isNotEmpty) {
      if (wish.productImageUrl!.startsWith('//')) {
        imageUrl = 'https:${wish.productImageUrl!}';
      } else if (!wish.productImageUrl!.startsWith('file://')) {
        imageUrl = wish.productImageUrl;
      }
    }

    return InkWell(
      onTap: () => _selectWish(wish.wishlistPk),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // 이미지
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: SizedBox(
                width: 50,
                height: 50,
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.whiteDark,
                            child: const Icon(Icons.image_not_supported, color: Colors.grey),
                          );
                        },
                      )
                    : Container(
                        color: AppColors.whiteDark,
                        child: const Icon(Icons.image_not_supported, color: Colors.grey),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            
            // 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    wish.productNickname,
                    style: AppTextStyles.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    wish.productName,
                    style: AppTextStyles.bodyExtraSmall.copyWith(color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // 가격
            Text(
              '$formattedPrice 원',
              style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
  
  // 위시 상세 컨텐츠
  Widget _buildWishDetailContent() {
    final wishState = ref.watch(wishProvider);
    final wish = _selectedWish ?? wishState.currentWish;
    
    // 로딩중이거나 데이터 없을 때
    if (wishState.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (wish == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: Text('위시 정보를 불러올 수 없습니다')),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상품 이미지와 닉네임 영역
          _buildProductHeaderSection(wish),
          
          // 디바이더
          const Divider(height: 1, thickness: 0.5),
          
          // 상품명 영역
          _buildProductNameSection(wish),
          
          // 디바이더
          const Divider(height: 1, thickness: 0.5),
          
          // 상품 금액 영역
          _buildProductPriceSection(wish),
          
          // 디바이더
          const Divider(height: 1, thickness: 0.5),
          
          // 달성 금액 영역 (읽기 전용)
          _buildAchievePriceSection(wish),
          
          // 디바이더
          const Divider(height: 1, thickness: 0.5),
          
          // 종료일 영역 (읽기 전용)
          _buildEndDateSection(),
          
          // 버튼 영역
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Button(
                    text: '삭제',
                    onPressed: () => _deleteWish(wish.wishlistPk),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Button(
                    text: '수정',
                    onPressed: () {
                      // 현재 활성화된 편집 필드의 저장 처리
                      if (_isEditingNickname || _isEditingProductName || 
                          _isEditingPrice || _isEditingUrl) {
                        _saveWish();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // 상품 이미지와 닉네임 영역
  Widget _buildProductHeaderSection(WishDetail wish) {
    // 이미지 URL 처리
    String? imageUrl;
    if (wish.productImageUrl != null && wish.productImageUrl!.isNotEmpty) {
      if (wish.productImageUrl!.startsWith('//')) {
        imageUrl = 'https:${wish.productImageUrl!}';
      } else if (!wish.productImageUrl!.startsWith('file://')) {
        imageUrl = wish.productImageUrl;
      }
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 상품 이미지
          ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Container(
              width: 50,
              height: 50,
              color: AppColors.whiteDark,
              child: imageUrl != null
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image_not_supported, color: Colors.grey);
                    },
                  )
                : const Icon(Icons.image_not_supported, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 16),
          
          // 닉네임 영역
          Expanded(
            child: _isEditingNickname
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    RoundInput(
                      controller: _nicknameController,
                      label: '상품명',
                      hintText: '위시 상품의 별명을 입력하세요',
                      onChanged: (value) => setState(() {}),
                      errorText: _nicknameController.text.isEmpty 
                        ? '상품명은 필수 입력 항목입니다.' 
                        : null,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isEditingNickname = false;
                              _nicknameController.text = wish.productNickname;
                            });
                          },
                          child: Text('취소', style: TextStyle(color: AppColors.textSecondary)),
                        ),
                        TextButton(
                          onPressed: () {
                            if (_nicknameController.text.isNotEmpty) {
                              _saveField('productNickname', _nicknameController.text);
                            }
                          },
                          child: Text('확인', style: TextStyle(color: AppColors.bluePrimary)),
                        ),
                      ],
                    ),
                  ],
                )
              : GestureDetector(
                  onTap: () {
                    // URL이 있으면 해당 URL 열기, 없으면 닉네임 편집 모드로 전환
                    if (wish.productUrl != null && wish.productUrl!.isNotEmpty) {
                      _launchURL(wish.productUrl!);
                    } else {
                      setState(() {
                        _isEditingNickname = true;
                      });
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              wish.productNickname,
                              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (wish.productUrl != null && wish.productUrl!.isNotEmpty) 
                            Icon(Icons.link, size: 16, color: AppColors.bluePrimary)
                        ],
                      ),
                      if (wish.productUrl != null && wish.productUrl!.isNotEmpty)
                        Text(
                          '링크 열기',
                          style: AppTextStyles.bodyExtraSmall.copyWith(color: AppColors.bluePrimary),
                        ),
                    ],
                  ),
                ),
          ),
        ],
      ),
    );
  }
  
  // 상품명 영역
  Widget _buildProductNameSection(WishDetail wish) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: _isEditingProductName
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              RoundInput(
                controller: _productNameController,
                label: '상품명',
                hintText: '상품에 대한 설명을 입력하세요',
                onChanged: (value) => setState(() {}),
                errorText: _productNameController.text.isEmpty 
                  ? '상세 설명은 필수 입력 항목입니다.' 
                  : null,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isEditingProductName = false;
                        _productNameController.text = wish.productName;
                      });
                    },
                    child: Text('취소', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                  TextButton(
                    onPressed: () {
                      if (_productNameController.text.isNotEmpty) {
                        _saveField('productName', _productNameController.text);
                      }
                    },
                    child: Text('확인', style: TextStyle(color: AppColors.bluePrimary)),
                  ),
                ],
              ),
            ],
          )
        : GestureDetector(
            onTap: () {
              setState(() {
                _isEditingProductName = true;
              });
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '상품명',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Text(
                  wish.productName,
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
    );
  }
  
  // 상품 금액 영역
  Widget _buildProductPriceSection(WishDetail wish) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: _isEditingPrice
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              RoundInput(
                controller: _priceController,
                label: '목표 금액',
                hintText: '목표 금액을 입력하세요',
                onChanged: (value) {
                  // 숫자만 허용하고 천 단위 쉼표 추가
                  if (value.isNotEmpty) {
                    final number = int.tryParse(value.replaceAll(',', '')) ?? 0;
                    final formatted = NumberFormat('#,###').format(number);
                    if (formatted != value) {
                      _priceController.value = _priceController.value.copyWith(
                        text: formatted,
                        selection: TextSelection.collapsed(offset: formatted.length),
                      );
                    }
                  }
                  setState(() {});
                },
                errorText: _validatePrice(),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isEditingPrice = false;
                        _priceController.text = NumberFormat('#,###').format(wish.productPrice);
                      });
                    },
                    child: Text('취소', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                  TextButton(
                    onPressed: () {
                      if (_validatePrice() == null) {
                        _saveField('productPrice', int.parse(_priceController.text.replaceAll(',', '')));
                      }
                    },
                    child: Text('확인', style: TextStyle(color: AppColors.bluePrimary)),
                  ),
                ],
              ),
            ],
          )
        : GestureDetector(
            onTap: () {
              setState(() {
                _isEditingPrice = true;
              });
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '상품 금액',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Text(
                  '${NumberFormat('#,###').format(wish.productPrice)} 원',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
    );
  }
  
  // 달성 금액 영역 (읽기 전용)
  Widget _buildAchievePriceSection(WishDetail wish) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '달성 금액',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            '${NumberFormat('#,###').format(wish.achievePrice)} 원',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
  
  // 종료일 영역 (읽기 전용, 이미지 기준 하드코딩)
  Widget _buildEndDateSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '종료일',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            '2025년 4월 10일',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
  
  // 가격 유효성 검사
  String? _validatePrice() {
    final value = _priceController.text;
    if (value.isEmpty) {
      return '목표 금액은 필수 입력 항목입니다.';
    }
    
    final number = int.tryParse(value.replaceAll(',', ''));
    if (number == null) {
      return '유효한 금액을 입력해주세요.';
    }
    
    return null;
  }
  
  // 단일 필드 저장 처리
  void _saveField(String fieldName, dynamic value) async {
    final wishPk = widget.wishPk ?? widget.currentWish?.wishlistPk;
    
    if (wishPk == null) {
      CompletionMessage.show(context, message: '위시 정보를 찾을 수 없습니다.');
      return;
    }

    try {
      // 위시리스트 수정 API 호출 (해당 필드만 업데이트)
      await ref.read(wishlistProvider.notifier).updateWishlist(
        wishlistPk: wishPk,
        productNickname: fieldName == 'productNickname' ? value : null,
        productName: fieldName == 'productName' ? value : null,
        productPrice: fieldName == 'productPrice' ? value : null,
        productUrl: fieldName == 'productUrl' ? value : null,
      );

      if (mounted) {
        // 해당 필드의 편집 모드 종료
        setState(() {
          if (fieldName == 'productNickname') _isEditingNickname = false;
          if (fieldName == 'productName') _isEditingProductName = false;
          if (fieldName == 'productPrice') _isEditingPrice = false;
          if (fieldName == 'productUrl') _isEditingUrl = false;
        });
        
        // 수정 성공 메시지
        CompletionMessage.show(context, message: '위시가 수정되었습니다.');
        
        // 위시 상세 정보 갱신
        ref.read(wishlistProvider.notifier).fetchWishlistDetail(wishPk);
      }
    } catch (e) {
      if (mounted) {
        // 수정 실패 메시지
        CompletionMessage.show(context, message: '위시 수정 중 오류가 발생했습니다: $e');
      }
    }
  }

  // 위시 수정 저장 처리 (현재 편집 중인 모든 필드)
  void _saveWish() async {
    if (_formkey.currentState?.validate() ?? false) {
      final wishPk = widget.wishPk ?? widget.currentWish?.wishlistPk;
      
      if (wishPk == null) {
        CompletionMessage.show(context, message: '위시 정보를 찾을 수 없습니다.');
        return;
      }

      try {
        // 위시리스트 수정 API 호출
        await ref.read(wishlistProvider.notifier).updateWishlist(
          wishlistPk: wishPk,
          productNickname: _isEditingNickname ? _nicknameController.text : null,
          productName: _isEditingProductName ? _productNameController.text : null,
          productPrice: _isEditingPrice ? int.parse(_priceController.text.replaceAll(',', '')) : null,
          productUrl: _isEditingUrl ? (_urlController.text.isEmpty ? null : _urlController.text) : null,
        );

        if (mounted) {
          // 수정 모드 종료
          setState(() {
            _isEditingNickname = false;
            _isEditingProductName = false;
            _isEditingPrice = false;
            _isEditingUrl = false;
          });
          
          // 수정 성공 메시지
          CompletionMessage.show(context, message: '위시가 수정되었습니다.');
          
          // 위시 상세 정보 갱신
          ref.read(wishlistProvider.notifier).fetchWishlistDetail(wishPk);
        }
      } catch (e) {
        if (mounted) {
          // 수정 실패 메시지
          CompletionMessage.show(context, message: '위시 수정 중 오류가 발생했습니다: $e');
        }
      }
    }
  }

  // 위시 삭제 처리
  void _deleteWish(int wishPk) async {
    // 확인 다이얼로그 표시
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('위시 삭제'),
        content: const Text('정말 이 위시를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      // 위시리스트 삭제 API 호출
      try {
        await ref.read(wishlistProvider.notifier).deleteWishlist(wishPk);
        
        if (mounted) {
          // 삭제 성공 메시지
          CompletionMessage.show(context, message: '위시가 삭제되었습니다.');
          // 모달 닫기
          Navigator.of(context).pop();
          // 위시 목록 갱신
          ref.refresh(wishProvider);
        }
      } catch (e) {
        if (mounted) {
          // 삭제 실패 메시지
          CompletionMessage.show(context, message: '위시 삭제 중 오류가 발생했습니다.');
        }
      }
    }
  }

  // 빈 목록 메시지
  String _getEmptyMessage(WishListTab tab) {
    switch (tab) {
      case WishListTab.pending: 
        return '대기중인 위시가 없습니다';
      case WishListTab.inProgress:
        return '진행중인 위시가 없습니다';
      case WishListTab.completed:
        return '완료된 위시가 없습니다';
    }
  }

  // 빈 목록 이미지
  String _getEmptyImage(WishListTab tab) {
    switch (tab) {
      case WishListTab.pending: 
        return 'assets/images/characters/charlying_down.png';
      case WishListTab.inProgress:
        return 'assets/images/characters/char_chair_phone.png';
      case WishListTab.completed:
        return 'assets/images/characters/char_angry_notebook.png';
    }
  }


}