package com.gbh.gbh_mm.user.controller;

import com.gbh.gbh_mm.common.dto.ApiResponse;
import com.gbh.gbh_mm.user.model.entity.CustomUserDetails;
import com.gbh.gbh_mm.user.model.request.*;
import com.gbh.gbh_mm.user.model.response.IdentityVerificationResponseDto;
import com.gbh.gbh_mm.user.model.response.LoginResponseDto;
import com.gbh.gbh_mm.user.model.response.SignUpResponseDto;
import com.gbh.gbh_mm.user.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/mm/auth")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @PostMapping("/identity-verify")
    public IdentityVerificationResponseDto requestVerification(@RequestBody IdentityVerificationRequestDto identityVerificationRequestDto){
        return userService.verify(identityVerificationRequestDto);
    }

    @PostMapping("/sign-up")
    public SignUpResponseDto signUp(@RequestBody SignUpRequestDto signUpRequestDto){
        return userService.register(signUpRequestDto);
    }

    @PostMapping("/login/pin")
    public LoginResponseDto loginByPin(@RequestBody LoginByPinRequestDto loginByPinRequestDto) {
        return userService.loginByPin(loginByPinRequestDto);
    }

    @PostMapping("/login/bio")
    public LoginResponseDto loginByBio(@RequestBody LoginByBioRequestDto loginByBioRequestDto) {
        return userService.loginByBio(loginByBioRequestDto);
    }
    @PostMapping("/reissue")
    public LoginResponseDto reissueToken(@RequestBody ReissueTokenRequestDto reissueTokenRequestDto) {
        return userService.reissueTokens(reissueTokenRequestDto.getRefreshToken());
    }

    @PostMapping("/logout")
    public String logout(@RequestHeader("Authorization") String bearerToken) {
        userService.logout(bearerToken);
        return "로그아웃 성공";
    }

    @GetMapping("/integrated-status")
    public Boolean checkIntegratedStatus(@AuthenticationPrincipal CustomUserDetails userDetails){
        return userService.isIntegratedAuthenticated(userDetails.getUserPk());
    }


}
