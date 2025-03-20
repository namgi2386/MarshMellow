import 'package:flutter/material.dart';
import 'package:marshmellow/core/theme/app_colors.dart';
import 'package:marshmellow/core/theme/app_text_styles.dart';

class TextInput extends StatefulWidget {
  final String label;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller; // 텍스트 인풋 컨트롤러
  final String? errorText; // 에러 텍스트
  final VoidCallback? onTap; // 텍스트 인풋 탭 이벤트
  final FocusNode? focusNode; // 포커스 노드
  final double? width; // 텍스트 인풋 너비

  const TextInput({
    super.key,
    required this.label,
    this.onChanged,
    this.readOnly = false,
    this.controller,
    this.errorText,
    this.onTap,
    this.focusNode,
    this.width,
  });

  @override
  State<TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
  late FocusNode _focusNode;
  TextEditingController? _controller;
  bool _isFocused = false;
  bool _hasText = false; // 텍스트 입력 여부 상태

  @override
  void initState() {
    super.initState();
    // 외부에서 제공된 focusNode가 있으면 사용, 없으면 내부에서 생성
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(TextInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      _focusNode.removeListener(_handleFocusChange);
      _focusNode = widget.focusNode ?? FocusNode();
      _focusNode.addListener(_handleFocusChange);
    }
  }

  // 포커스 상태 변경 처리
  void _handleFocusChange() {
    if (_isFocused != _focusNode.hasFocus) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  // 텍스트 입력 상태 업데이트
  void _updateTextStatus() {
    final hasText = (widget.controller?.text.isNotEmpty ?? false) ||
        (_controller?.text.isNotEmpty ?? false);
    if (_hasText != hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  // 텍스트 초기화 함수
  void _clearText() {
    if (widget.controller != null) {
      widget.controller!.clear();
    } else if (_controller != null) {
      _controller!.clear();
    }

    if (widget.onChanged != null) {
      widget.onChanged!('');
    }

    setState(() {
      _hasText = false;
    });
  }

  @override
  void dispose() {
    // 내부에서 생성한 focusNode와 controller만 dispose
    if (widget.focusNode == null) {
      _focusNode.removeListener(_handleFocusChange);
      _focusNode.dispose();
    }
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 외부에서 제공된 controller 또는 내부에서 생성한 controller 사용
    if (widget.controller != null) {
      // 기존 컨트롤러가 있으면 dispose하고 새 컨트롤러 사용
      _controller?.dispose();
      _controller = null;
      // 컨트롤러에 리스너 추가
      widget.controller!.addListener(_updateTextStatus);
      // 현재 컨트롤러의 텍스트 상태 확인
      _hasText = widget.controller!.text.isNotEmpty;
    } else if (_controller == null) {
      _controller = TextEditingController();
      _controller!.addListener(_updateTextStatus);
    }
    final effectiveController = widget.controller ?? _controller!;

    // 색상 정의
    final Color borderColor = widget.errorText != null
        ? AppColors.warnning
        : _isFocused
            ? AppColors.textPrimary // 포커스 상태일 경우
            : AppColors.textSecondary; // 포커스 상태가 아닐 경우

    final Color textColor =
        _isFocused ? AppColors.textPrimary : AppColors.textSecondary;

    // 화면의 전체 너비를 가져옵니다.
    final double screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            // 너비를 화면 너비의 90%로 설정
            width: widget.width ?? screenWidth * 0.9,
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(5),
              color: AppColors.whiteLight,
            ),
            child: Stack(
              // alignment 속성 제거하여 기본값(topLeft)으로 설정
              children: [
                TextField(
                  controller: effectiveController,
                  focusNode: _focusNode,
                  onChanged: (value) {
                    // 텍스트 변경 시 상태 업데이트
                    setState(() {
                      _hasText = value.isNotEmpty;
                    });
                    if (widget.onChanged != null) {
                      widget.onChanged!(value);
                    }
                  },
                  readOnly: widget.readOnly,
                  onTap: widget.onTap,
                  cursorColor: textColor,
                  decoration: InputDecoration(
                    labelText: widget.label,
                    labelStyle: AppTextStyles.bodySmall.copyWith(
                      color: textColor,
                    ),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.only(
                      top: 16,
                      right: 40, // 오른쪽에 X 버튼을 위한 공간 확보
                    ),
                  ),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: textColor,
                  ),
                ),
                // X 버튼 - 포커스가 있고 텍스트가 있을 때만 표시
                if (_isFocused && _hasText)
                  Positioned(
                    right: 0,
                    bottom: 10,
                    child: GestureDetector(
                      onTap: _clearText,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.cancel_outlined,
                            size: 15,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (widget.errorText != null)
            Container(
              width: widget.width ?? screenWidth * 0.9,
              padding: const EdgeInsets.only(left: 16, top: 4),
              margin: const EdgeInsets.only(bottom: 23),
              child: Text(
                widget.errorText!,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w300,
                  color: AppColors.warnning,
                ),
              ),
            ),
          if (widget.errorText == null) const SizedBox(height: 23),
        ],
      ),
    );
  }
}

// ===================== 사용 예시 =====================
/*
// TextInput 위젯 사용 예시

// 1. 기본 사용법
TextInput(
  label: '이름',
  onChanged: (value) {
    print('이름: $value');
  },
)

// 2. 컨트롤러를 사용한 방법
final TextEditingController _nameController = TextEditingController();

TextInput(
  label: '이름',
  controller: _nameController,
  onChanged: (value) {
    print('입력된 이름: $value');
    // 컨트롤러를 통해서도 접근 가능: _nameController.text
  },
)

// 3. 유효성 검증 사용 예시
String? _emailError;

void _validateEmail(String email) {
  final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  if (email.isEmpty) {
    setState(() => _emailError = null);
  } else if (!emailRegex.hasMatch(email)) {
    setState(() => _emailError = '유효한 이메일 주소를 입력해주세요');
  } else {
    setState(() => _emailError = null);
  }
}

TextInput(
  label: '이메일',
  errorText: _emailError,
  onChanged: (value) {
    _validateEmail(value);
    print('이메일: $value');
  },
)

// 4. 읽기 전용 및 탭 이벤트 사용 예시
TextInput(
  label: '생년월일',
  readOnly: true, // 직접 입력 불가능, 탭으로만 입력 가능
  controller: _birthController,
  onTap: () {
    // 날짜 선택 다이얼로그 표시
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    ).then((selectedDate) {
      if (selectedDate != null) {
        _birthController.text = '${selectedDate.year}-${selectedDate.month}-${selectedDate.day}';
      }
    });
  },
)
*/
