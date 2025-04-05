import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:marshmellow/presentation/pages/budget/widgets/wish/wish_list_input_widget.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' as intl;
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/presentation/widgets/button/button.dart';
import 'package:marshmellow/presentation/widgets/completion_message/completion_message.dart';
import 'package:marshmellow/presentation/viewmodels/wishlist/wishlist_providers.dart';


/*
  위시리스트 생성 페이지
*/
class WishlistCreationPage extends ConsumerStatefulWidget {
  const WishlistCreationPage({super.key});

  @override
  ConsumerState<WishlistCreationPage> createState() => _WishlistCreationPageState();
}

class _WishlistCreationPageState extends ConsumerState<WishlistCreationPage> {
  final _formKey = GlobalKey<FormState>();
  
  // 컨트롤러 정의
  final _nickNameController = TextEditingController();
  final _productNameController = TextEditingController();
  final _priceController = TextEditingController();
  final _urlController = TextEditingController();

  // 이미지
  File? _selectedImage;
  bool _showInputFields = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // 위시리스트 생성 상태 초기화
    Future.microtask(() {
      ref.read(wishlistCreationProvider.notifier).resetState();
    });
  }

  @override
  void dispose() {
    _nickNameController.dispose();
    _productNameController.dispose();
    _priceController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  // 이미지 선택 함수
  Future<void> _pickImage() async {
    try {
      final ImagePicker imagePicker = ImagePicker();
      final XFile? image = await imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        imageQuality: 80,
      );

      if (image == null) return;

      setState(() {
        _selectedImage = File(image.path);
      });
    } catch (e) {
      // Handle error
      print('Error picking wishlist image: $e');
    }
  }

  // 금액 입력 포맷 함수
  void _formatPrice(String value) {
    if (value.isNotEmpty) {
      final number = int.tryParse(value.replaceAll(',', '')) ?? 0;
      final formatted = intl.NumberFormat('#,###').format(number);
      
      if (formatted != value) {
        _priceController.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    }
  }

  // 위시리스트 생성 함수
  Future<void> _createWishlist() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final price = int.parse(_priceController.text.replaceAll(',', ''));

        // URL 형식 수정
        String formattedUrl = _urlController.text;
        if (formattedUrl.isNotEmpty && !formattedUrl.startsWith('http')) {
          formattedUrl = 'http://$formattedUrl';
        }

        // 위시리스트 생성 요청
        await ref.read(wishlistCreationProvider.notifier).createWishlist(
          productNickname: _nickNameController.text,
          productName: _productNameController.text.isEmpty ? _nickNameController.text : _productNameController.text,
          productPrice: price,
          productUrl: formattedUrl,
          imageFile: _selectedImage,              
        );

        // 상태 확인
        final state = ref.read(wishlistCreationProvider);

        if (!state.isLoading && state.errorMessage == null) {
          if (mounted) {
            CompletionMessage.show(context, message: '위시가 성공적으로 생성되었습니다!');

            // 위시리스트 목록 갱신
            ref.read(wishlistProvider.notifier).fetchWishlists();

            // 홈 화면으로 돌아가기
            Future.delayed(const Duration(seconds: 2), () {
              Navigator.of(context).pop();
            });
          }
        } else if (state.errorMessage != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('위시리스트 생성 중 오류가 발생했습니다: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 위시리스트 생성 상태 관찰
    final creationState = ref.watch(wishlistCreationProvider);
    final isLoading = _isLoading || creationState.isLoading;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('위시리스트'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // 알림 기능
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              // 프로필 기능
            },
          ),
        ],
      ),
      body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 첫 번째 화면: 상품명 질문
                  if (!_showInputFields)
                    _buildInitialQuestion(),
                  
                  // 두 번째 화면 이후: 입력 필드들
                  if (_showInputFields)
                    _buildInputFields(),
                ],
              ),
            ),
          ),
    );
  }
  
  // 초기 질문 화면 위젯
  Widget _buildInitialQuestion() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 80),
        
        // 캐릭터 이미지
        Image.asset(
          'assets/images/characters/char_angry_notebook.png',
          width: 150,
          height: 150,
        ),
        
        const SizedBox(height: 20),
        
        // 질문 텍스트
        Text(
          '어떤 목표 상품은 무엇인가요?',
          style: AppTextStyles.bodyMedium,
        ),
        
        const SizedBox(height: 16),
        
        // 입력 필드
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: WishlistInput(
            controller: _nickNameController,
            hintText: '상품명을 입력하세요',
            onChanged: (value) => setState(() {}),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // 다음 버튼
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Button(
            text: '다음',
            onPressed: _nickNameController.text.isNotEmpty
              ? () {
                  setState(() {
                    _showInputFields = true;
                  });
                }
              : null,
          ),
        ),
      ],
    );
  }
  
  // 모든 입력 필드 위젯
  Widget _buildInputFields() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이미지 있으면 이미지, 없으면 캐릭터
          if (_selectedImage != null)
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: FileImage(_selectedImage!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
          else
            Center(
              child: Image.asset(
                'assets/images/characters/char_angry_notebook.png',
                width: 100,
                height: 100,
              ),
            ),
            
          const SizedBox(height: 20),
          
          // 이름 입력
          WishlistInput(
            controller: _nickNameController,
            label: '상품명',
            hintText: '상품명을 입력하세요',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '상품명은 필수 입력 항목입니다.';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 12),
          
          // 상품 금액 입력
          WishlistInput(
            controller: _priceController,
            prefixIcon: const Text('상품 금액'),
            hintText: '금액을 입력하세요',
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: (value) => _formatPrice(value),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '상품 금액은 필수 입력 항목입니다.';
              }
              return null;
            },
            suffix: const Text('원', style: TextStyle(color: Colors.grey)),
          ),
          
          const SizedBox(height: 12),
          
          // 종료일 입력 (현재는 하드코딩)
          WishlistInput(
            enabled: false,
            initialValue: '2024년 04월 10일',
            prefixIcon: const Text('목표 날짜'),
          ),
          
          const SizedBox(height: 12),
          
          // URL 입력
          WishlistInput(
            controller: _urlController,
            prefixIcon: const Text('링크'),
            hintText: '쇼핑몰 링크가 있으면 넣어주세요',
            suffix: Icon(Icons.link, color: AppColors.bluePrimary),
          ),
          
          const SizedBox(height: 20),
          
          // 이미지 업로드 텍스트
          Center(
            child: Text(
              '위시의 별칭이 있나요?\n이미지도 넣다면 넣어주세요!',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 이미지 업로드 필드
          Row(
            children: [
              Expanded(
                child: WishlistInput(
                  controller: _productNameController,
                  hintText: '상세 설명 (선택)',
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    _selectedImage != null 
                        ? Icons.check_circle
                        : Icons.camera_alt,
                    color: _selectedImage != null 
                        ? AppColors.bluePrimary
                        : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 40),
          
          // 캐릭터와 메시지
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.blueLight.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/characters/char_width_smile.png',
                  width: 70,
                  height: 70,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '매일 7,120원씩\n저축할 계획이세요?',
                        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '목표금액 자동 계산되어 적용',
                        style: AppTextStyles.bodyExtraSmall.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 저장 버튼
          Button(
            text: '저장하기',
            onPressed: _createWishlist,
          ),
        ],
      ),
    );
  }
}