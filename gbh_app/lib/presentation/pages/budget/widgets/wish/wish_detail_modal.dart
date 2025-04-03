import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/data/models/wishlist/wish_model.dart';
import 'package:marshmellow/presentation/viewmodels/wishlist/wish_provider.dart';
import 'package:marshmellow/presentation/viewmodels/wishlist/wishlist_providers.dart';
import 'package:marshmellow/presentation/widgets/button/button.dart';
import 'package:marshmellow/presentation/widgets/completion_message/completion_message.dart';
import 'package:marshmellow/presentation/widgets/round_input/round_input.dart';

/*
  위시 상세 조회 모달 위젯
  : 선택한 위시의 상세 내역을 보여주며 수정/삭제 기능을 제공
*/
class WishDetailModal extends ConsumerStatefulWidget {
  final int? wishPk;
  final WishDetail? currentWish;

  const WishDetailModal({
    Key? key,
    this.wishPk,
    this.currentWish,
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
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();

    // 위시 상세 정보 로드
    if (widget.wishPk != null && widget.currentWish == null) {
      Future.microtask(() {
        ref.read(wishProvider.notifier).fetchWishDetail(widget.wishPk!);
      });
    }
  }

  void _initializeControllers() {
    final wish = widget.currentWish;
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

  @override
  Widget build(BuildContext context) {
    final wishState = ref.watch(wishProvider);
    final wish = widget.currentWish ?? wishState.currentWish;
    
    // 로딩중이거나 데이터 없을 때
    if (wishState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (wish == null && !_isEditing) {
      return const Center(
        child: Text('위시 정보를 불러올 수 없습니다'),
      );
    }

    return Form(
      key: _formkey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 탭 영역 (이미지에 맞게 추가)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTab('대기', false),
                _buildTab('진행중', true),
                _buildTab('완료', false),
              ],
            ),
          ),
          
          // 위시 정보 영역 (이미지처럼 간소화)
          _buildWishInfoCard(wish),
          
          // 버튼 영역
          Padding(
            padding: const EdgeInsets.all(16),
            child: _isEditing ? _buildEditingButtons() : _buildViewingButtons(wish!),
          ),
        ],
      ),
    );
  }
  
  // 탭 위젯
  Widget _buildTab(String title, bool isSelected) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.blueLight : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? AppColors.bluePrimary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
  
  // 위시 정보 카드
  Widget _buildWishInfoCard(WishDetail? wish) {
    // 위시 정보가 없으면 빈 카드
    if (wish == null && !_isEditing) {
      return Container();
    }
    
    // 이미지 URL 처리
    String? imageUrl;
    if (wish?.productImageUrl != null && wish!.productImageUrl!.isNotEmpty) {
      if (wish.productImageUrl!.startsWith('//')) {
        imageUrl = 'https:${wish.productImageUrl!}';
      } else if (!wish.productImageUrl!.startsWith('file://')) {
        imageUrl = wish.productImageUrl;
      }
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상품 이미지와 닉네임 영역
          Row(
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
              
              // 닉네임 영역 (편집 모드인 경우 입력 필드, 아닌 경우 텍스트로 표시)
              Expanded(
                child: _isEditing
                  ? RoundInput(
                      controller: _nicknameController,
                      label: '상품명',
                      hintText: '위시 상품의 별명을 입력하세요',
                      onChanged: (value) => setState(() {}),
                      errorText: _nicknameController.text.isEmpty 
                        ? '상품명은 필수 입력 항목입니다.' 
                        : null,
                    )
                  : GestureDetector(
                      onTap: () {
                        // URL이 있으면 해당 URL 열기
                        if (wish?.productUrl != null && wish!.productUrl!.isNotEmpty) {
                          _launchURL(wish.productUrl!);
                        } else {
                          // URL이 없으면 편집 모드로 전환
                          setState(() {
                            _isEditing = true;
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
                                  wish?.productNickname ?? '',
                                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (wish?.productUrl != null && wish!.productUrl!.isNotEmpty) 
                                Icon(Icons.link, size: 16, color: AppColors.bluePrimary)
                            ],
                          ),
                          if (wish?.productUrl != null && wish!.productUrl!.isNotEmpty)
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
          
          const SizedBox(height: 16),
          
          // 상품명 입력 필드 (편집 모드일 때만)
          if (_isEditing) 
            Column(
              children: [
                RoundInput(
                  controller: _productNameController,
                  label: '상세 설명',
                  hintText: '상품에 대한 설명을 입력하세요',
                  onChanged: (value) => setState(() {}),
                  errorText: _productNameController.text.isEmpty 
                    ? '상세 설명은 필수 입력 항목입니다.' 
                    : null,
                ),
                const SizedBox(height: 12),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '상품 금액',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  '${NumberFormat('#,###').format(wish?.productPrice ?? 0)} 원',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 16),
                
                Text(
                  '달성 금액',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  '${NumberFormat('#,###').format(wish?.achievePrice ?? 0)} 원',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 16),
                
                Text(
                  '종료일',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  '2025년 4월 10일', // 이미지를 기준으로 하드코딩
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          
          // 가격 입력 필드 (편집 모드일 때만)
          if (_isEditing)
            Column(
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
                const SizedBox(height: 12),
                
                // URL 입력 (편집 모드일 때만)
                RoundInput(
                  controller: _urlController,
                  label: '상품 URL',
                  hintText: '상품 URL을 입력하세요',
                  onChanged: (value) => setState(() {}),
                ),
              ],
            ),
        ],
      ),
    );
  }
  
  // 가격 유효성 검사
  String? _validatePrice() {
    if (!_isEditing) return null;
    
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
  
  // 조회 모드 버튼
  Widget _buildViewingButtons(WishDetail wish) {
    return Row(
      children: [
        Expanded(
          child: Button(
            text: '삭제하기',
            onPressed: () => _deleteWish(wish.wishlistPk),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Button(
            text: '수정하기',
            onPressed: () {
              setState(() {
                _isEditing = true;
              });
            },
          ),
        ),
      ],
    );
  }

  // 편집 모드 버튼 (취소/저장)
  Widget _buildEditingButtons() {
    return Row(
      children: [
        Expanded(
          child: Button(
            text: '취소',
            onPressed: () {
              setState(() {
                _isEditing = false;
                // 컨트롤러 값 원복
                _initializeControllers();
              });
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Button(
            text: '저장',
            onPressed: _saveWish,
          ),
        ),
      ],
    );
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

  // 위시 수정 저장 처리
  void _saveWish() async {
    if (_formkey.currentState?.validate() ?? false) {
      final wishPk = widget.wishPk ?? widget.currentWish?.wishlistPk;
      
      if (wishPk == null) {
        CompletionMessage.show(context, message: '위시 정보를 찾을 수 없습니다.');
        return;
      }

      // 입력값 가져오기
      final nickname = _nicknameController.text;
      final productName = _productNameController.text;
      final price = int.parse(_priceController.text.replaceAll(',', ''));
      final url = _urlController.text;

      try {
        // 위시리스트 수정 API 호출
        await ref.read(wishlistProvider.notifier).updateWishlist(
          wishlistPk: wishPk,
          productNickname: nickname,
          productName: productName,
          productPrice: price,
          productUrl: url.isEmpty ? null : url,
        );

        if (mounted) {
          // 수정 모드 종료
          setState(() {
            _isEditing = false;
          });
          
          // 수정 성공 메시지
          CompletionMessage.show(context, message: '위시가 수정되었습니다.');
          
          // 위시 상세 정보 갱신
          ref.read(wishProvider.notifier).fetchWishDetail(wishPk);
        }
      } catch (e) {
        if (mounted) {
          // 수정 실패 메시지
          CompletionMessage.show(context, message: '위시 수정 중 오류가 발생했습니다: $e');
        }
      }
    }
  }
}