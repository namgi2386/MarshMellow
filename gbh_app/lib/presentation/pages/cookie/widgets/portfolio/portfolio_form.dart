import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';
import 'package:marshmellow/core/constants/icon_path.dart';
import 'package:marshmellow/presentation/pages/cookie/widgets/portfolio/portfolio_fields.dart';
import 'package:marshmellow/presentation/widgets/button/button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:marshmellow/presentation/viewmodels/portfolio/portfolio_viewmodel.dart';
import 'package:marshmellow/presentation/widgets/completion_message/completion_message.dart';

class PortfolioForm extends ConsumerStatefulWidget {
  final String fileName;

  const PortfolioForm({
    super.key,
    this.fileName = "파일명", // 기본 파일명
  });

  @override
  ConsumerState<PortfolioForm> createState() => _PortfolioFormState();
}

class _PortfolioFormState extends ConsumerState<PortfolioForm> {
  // 상태 변수
  String _category = "";
  String _fileName = "";
  String _memo = "";
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;
  File? _selectedFile;
  int? _categoryPk; // 카테고리 PK 추가

  @override
  void initState() {
    super.initState();
    // 파일명 초기화
    _fileName = widget.fileName;
    // 포트폴리오 카테고리 목록 불러오기
    _loadCategories();
  }

  // 카테고리 목록 불러오기
  Future<void> _loadCategories() async {
    await ref.read(portfolioViewModelProvider.notifier).loadCategories();
  }

  // 카테고리 업데이트
  void _updateCategory(String category) {
    setState(() {
      _category = category;

      // 카테고리에 해당하는 PK 찾기
      final categories = ref.read(portfolioViewModelProvider).categories;
      final selectedCategory = categories.firstWhere(
        (c) => c.portfolioCategoryName == category,
        orElse: () => throw Exception('카테고리를 찾을 수 없습니다'),
      );
      _categoryPk = selectedCategory.portfolioCategoryPk;
    });
  }

  // 파일명 업데이트
  void _updateFileName(String fileName) {
    setState(() {
      _fileName = fileName;
    });
  }

  // 메모 업데이트
  void _updateMemo(String memo) {
    setState(() {
      _memo = memo;
    });
  }

  // 날짜 업데이트
  void _updateDate(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  // 파일 선택
  Future<void> _selectFile() async {
    // 파일 선택기 열기
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      // 선택된 파일 경로
      String filePath = result.files.single.path!;

      // 파일 객체 생성 및 파일명 업데이트
      setState(() {
        _selectedFile = File(filePath);
        _fileName = result.files.single.name;
      });

      // 디버그용 로그
      print('Selected file: $filePath');
    }
  }

  // 저장 기능
  Future<void> _savePortfolio() async {
    // 필수 필드 검증
    if (_selectedFile == null) {
      CompletionMessage.show(context, message: '파일 선택.');
      return;
    }


    if (_fileName.isEmpty) {
      CompletionMessage.show(context, message: '파일명');
      return;
    }

    // 로딩 상태 설정
    setState(() {
      _isSaving = true;
    });

    try {
      // 뷰모델을 통해 포트폴리오 등록 요청
      final portfolio =
          await ref.read(portfolioViewModelProvider.notifier).createPortfolio(
                file: _selectedFile!,
                portfolioMemo: _memo,
                fileName: _fileName,
                portfolioCategoryPk: _categoryPk!,
              );

      // 성공적으로 등록된 경우
      if (portfolio != null) {
        CompletionMessage.show(context, message: '파일이 등록되었습니다.');
        // 화면 닫기
        Navigator.of(context).pop(true);
      } else {
        // 에러 메시지는 뷰모델에서 state.errorMessage에 설정됨
        final errorMessage = ref.read(portfolioViewModelProvider).errorMessage;
        CompletionMessage.show(context, message: errorMessage ?? '등록에 실패했습니다.');
      }
    } catch (e) {
      CompletionMessage.show(context, message: '오류가 발생했습니다: $e');
    } finally {
      // 로딩 상태 해제
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 메인 콘텐츠
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 파일 정보 헤더
              _buildFileHeader(),

              const Divider(
                  height: 1, thickness: 1, color: AppColors.greyLight),

              // 폼 필드들
              _buildFormFields(context),
            ],
          ),
        ),

        // 하단 저장 버튼
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildSaveButton(),
        ),
      ],
    );
  }

  // 파일 정보 헤더 위젯
  Widget _buildFileHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 파일 아이콘과 이름을 구성하는 Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 파일명과 아이콘을 Stack으로 배치하여 바로 붙이기
              Expanded(
                child: Stack(
                  children: [
                    // 파일명 텍스트 - 더 짧게 줄여 아이콘 공간 확보
                    Padding(
                      padding: const EdgeInsets.only(right: 24), // 아이콘 공간 확보
                      child: Text(
                        _fileName,
                        style: AppTextStyles.modalTitle.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    // 파일 아이콘 - Positioned로 텍스트 길이에 상관없이 오른쪽에 배치
                    Positioned(
                      right: 0,
                      top: 4, // 아이콘 위치 미세 조정
                      child: GestureDetector(
                        onTap: _selectFile, // 파일 선택 메서드 연결
                        child: SvgPicture.asset(
                          IconPath.paperclip,
                          width: 20,
                          height: 20,
                          colorFilter: ColorFilter.mode(
                            AppColors.textPrimary,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 폼 필드들 위젯
  Widget _buildFormFields(BuildContext context) {
    // 포트폴리오 상태 가져오기
    final portfolioState = ref.watch(portfolioViewModelProvider);

    return Container(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        children: [
          // 카테고리 필드
          PortfolioFields.categoryField(
            context: context,
            selectedCategory: _category,
            onCategorySelected: _updateCategory,
            enabled: !_isSaving && !portfolioState.isLoading,
          ),

          // 파일명 필드
          PortfolioFields.editableFileNameField(
            fileName: _fileName,
            onFileNameChanged: _updateFileName,
            enabled: !_isSaving,
          ),

          // 메모/키워드 필드
          PortfolioFields.editableMemoField(
            memo: _memo,
            onMemoChanged: _updateMemo,
            enabled: !_isSaving,
          ),

          // 날짜 필드
          PortfolioFields.dateField(
            context: context,
            ref: ref,
            selectedDate: _selectedDate,
            onDateChanged: _updateDate,
            includeTime: false, // 날짜만 사용 (시간 제외)
            enabled: !_isSaving,
          ),
        ],
      ),
    );
  }

  // 저장 버튼 위젯
  Widget _buildSaveButton() {
    // 포트폴리오 상태 가져오기
    final portfolioState = ref.watch(portfolioViewModelProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Button(
        text: "저장하기",
        onPressed:
            (_isSaving || portfolioState.isLoading) ? null : _savePortfolio,
        isDisabled: _isSaving || portfolioState.isLoading,
        width: double.infinity,
        height: 50,
      ),
    );
  }
}
