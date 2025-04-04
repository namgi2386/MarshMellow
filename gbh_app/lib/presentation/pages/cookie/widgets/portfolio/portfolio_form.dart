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

  @override
  void initState() {
    super.initState();
    // 파일명 초기화
    _fileName = widget.fileName;
  }

  // 카테고리 업데이트
  void _updateCategory(String category) {
    setState(() {
      _category = category;
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

  // 저장 기능
  void _savePortfolio() {
    setState(() {
      _isSaving = true;
    });

    // 저장 로직 구현 (예: API 호출, 로컬 저장 등)

    // 저장 완료 후 화면 닫기
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        Navigator.of(context).pop();
      }
    });
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
                        onTap: () async {
                          // 파일 선택기 열기
                          FilePickerResult? result =
                              await FilePicker.platform.pickFiles(
                            type: FileType.any,
                            allowMultiple: false,
                          );

                          if (result != null &&
                              result.files.single.path != null) {
                            // 선택된 파일 경로
                            String filePath = result.files.single.path!;

                            // 파일명 업데이트
                            setState(() {
                              _fileName = result.files.single.name;
                              // 여기에 선택된 파일의 내용을 처리하는 로직 추가 가능
                            });

                            // 디버그용 로그
                            print('Selected file: $filePath');
                          }
                        },
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
    return Container(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        children: [
          // 카테고리 필드
          PortfolioFields.categoryField(
            context: context,
            selectedCategory: _category,
            onCategorySelected: _updateCategory,
            enabled: !_isSaving,
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
    return Container(
      padding: const EdgeInsets.all(16),
      child: Button(
        text: "저장하기",
        onPressed: _isSaving ? null : _savePortfolio,
        isDisabled: _isSaving,
        width: double.infinity,
        height: 50,
      ),
    );
  }
}
