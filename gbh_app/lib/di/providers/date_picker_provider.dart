// lib/di/providers/date_picker_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

// DatePicker 상태를 관리하는 클래스
class DatePickerState {
  final bool isVisible; // 표시 여부
  final Offset? position; // 표시 위치
  final DateRangePickerSelectionMode selectionMode; // 선택 모드
  final PickerDateRange? selectedRange; // 선택된 범위
  final DateTime? selectedDate; // 선택된 날짜
  final List<DateTime>? selectedDates; // 선택된 날짜들
  
  DatePickerState({
    this.isVisible = false,
    this.position,
    this.selectionMode = DateRangePickerSelectionMode.single,
    this.selectedRange,
    this.selectedDate,
    this.selectedDates,
  });
  
  // 상태 복사본 생성 메서드 (불변성 유지)
  DatePickerState copyWith({
    bool? isVisible,
    Offset? position,
    DateRangePickerSelectionMode? selectionMode,
    PickerDateRange? selectedRange,
    DateTime? selectedDate,
    List<DateTime>? selectedDates,
  }) {
    return DatePickerState(
      isVisible: isVisible ?? this.isVisible,
      position: position ?? this.position,
      selectionMode: selectionMode ?? this.selectionMode,
      selectedRange: selectedRange ?? this.selectedRange,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedDates: selectedDates ?? this.selectedDates,
    );
  }
}

// DatePicker 상태 Notifier
class DatePickerNotifier extends StateNotifier<DatePickerState> {
  DatePickerNotifier() : super(DatePickerState());
  
  // DatePicker 표시하기
  void showDatePicker({
    required Offset position,
    DateRangePickerSelectionMode? selectionMode,
    PickerDateRange? initialRange,
    DateTime? initialDate,
    List<DateTime>? initialDates,
  }) {
    state = state.copyWith(
      isVisible: true,
      position: position,
      selectionMode: selectionMode,
      selectedRange: initialRange,
      selectedDate: initialDate,
      selectedDates: initialDates,
    );
  }
  
  // DatePicker 숨기기
  void hideDatePicker() {
    state = state.copyWith(isVisible: false);
  }
  
  // 선택된 날짜 범위 업데이트
  void updateSelectedRange(PickerDateRange range) {
    state = state.copyWith(selectedRange: range);
  }
  
  // 선택된 날짜 업데이트
  void updateSelectedDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }
  
  // 선택된 날짜들 업데이트
  void updateSelectedDates(List<DateTime> dates) {
    state = state.copyWith(selectedDates: dates);
  }
}

// 전역 프로바이더 정의
final datePickerProvider = StateNotifierProvider<DatePickerNotifier, DatePickerState>((ref) {
  return DatePickerNotifier();
});