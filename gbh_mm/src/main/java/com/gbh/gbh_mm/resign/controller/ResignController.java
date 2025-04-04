//package com.gbh.gbh_mm.resign.controller;
//
//import com.gbh.gbh_mm.resign.model.response.AverageSpendResponseDto;
//import com.gbh.gbh_mm.resign.service.ResignService;
//import com.gbh.gbh_mm.user.model.entity.CustomUserDetails;
//import lombok.RequiredArgsConstructor;
//import org.springframework.security.core.annotation.AuthenticationPrincipal;
//import org.springframework.web.bind.annotation.GetMapping;
//import org.springframework.web.bind.annotation.RestController;
//
//@RestController
//@RequiredArgsConstructor
//public class ResignController {
//
//    private final ResignService resignService;
//
//    // 한달 평균지출
//    @GetMapping("/average-spending")
//    public AverageSpendResponseDto getAverage(@AuthenticationPrincipal CustomUserDetails customUserDetails) {
//        return resignService.getAverage(customUserDetails);
//    }
//
//    // 현금성 자산 다 가져오기
//
//}
