// lib/presentation/pages/test/datepickertest.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:marshmellow/presentation/widgets/datepicker/date_picker_button.dart';
import 'package:marshmellow/di/providers/date_picker_provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class Datepickertest extends ConsumerWidget {
  const Datepickertest({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 현재 선택된 날짜 범위 가져오기
    final datePickerState = ref.watch(datePickerProvider);
    String selectedRange = "날짜를 선택하세요";
    
    // 선택된 날짜 범위가 있으면 표시
    if (datePickerState.selectedRange != null) {
      final startDate = datePickerState.selectedRange!.startDate;
      final endDate = datePickerState.selectedRange!.endDate ?? startDate;
      
      if (startDate != null) {
        selectedRange = "${startDate.year}/${startDate.month}/${startDate.day}";
        
        if (endDate != null && endDate != startDate) {
          selectedRange += " - ${endDate.year}/${endDate.month}/${endDate.day}";
        }
      }
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('테스트 페이지'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Container(
          color: Colors.green,
          width: MediaQuery.of(context).size.width*0.9, // 화면의 90%
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,  // 시작 부분부터 배치
            crossAxisAlignment: CrossAxisAlignment.start,  // 좌측 정렬 추가
            children: [
              const Text(
                '테스트 페이지입니다',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 20),
              
              // 선택된 날짜 범위 표시
              Text(selectedRange, style: TextStyle(fontSize: 16)),
              
              const SizedBox(height: 20),
              
              // DatePicker를 표시할 버튼
              DatePickerButton(
                child: Text("전체"),
                selectionMode: DateRangePickerSelectionMode.range,
                // style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.blue)), // 스타일적용방법 1
                style: ElevatedButton.styleFrom( backgroundColor: Colors.blue,),// 스타일적용방법 2
                onDateRangeSelected: (range) {
                  // 필요시 추가 작업 수행
                  print("선택된 날짜 범위: $range");
                },
              ),
              
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  context.pop();
                },
                child: const Text('홈으로 돌아가기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}