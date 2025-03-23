package com.gbh.gbh_mm.user.controller;

import com.gbh.gbh_mm.user.model.request.IdentityVerificationRequestDto;
import com.gbh.gbh_mm.user.model.response.IdentityVerificationResponseDto;
import com.gbh.gbh_mm.user.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

//    서버가 이메일을 수신하여 Redis에 저장된 정보와 일치하는지 확인 후 본인 인증을 완료합니다.
    @PostMapping("/api/mm/auth/identity-verify")
    public IdentityVerificationResponseDto requestVerification(@RequestBody IdentityVerificationRequestDto identityVerificationRequestDto){
        return userService.verify(identityVerificationRequestDto);
    }

//    @PostMapping("/api/mm")

}
