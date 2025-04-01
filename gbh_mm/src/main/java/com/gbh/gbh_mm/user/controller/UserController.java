package com.gbh.gbh_mm.user.controller;

import com.gbh.gbh_mm.common.dto.ApiResponse;
import com.gbh.gbh_mm.user.model.entity.CustomUserDetails;
import com.gbh.gbh_mm.user.model.request.*;
import com.gbh.gbh_mm.user.model.response.*;
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
    public IdentityVerificationResponseDto requestVerification(@RequestBody IdentityVerificationRequestDto identityVerificationRequestDto) {
        return userService.verify(identityVerificationRequestDto);
    }

    @PostMapping("/sign-up")
    public SignUpResponseDto signUp(@RequestBody SignUpRequestDto signUpRequestDto) {
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
    public ApiResponse<?> logout(@RequestHeader("Authorization") String bearerToken) {
        userService.logout(bearerToken);
        return ApiResponse.builder().code(200).message("로그아웃 성공").build();
    }

    @GetMapping("/cert/exist")
    public CertExistResponseDto isExistCertificate(@AuthenticationPrincipal CustomUserDetails userDetails) {
        return userService.checkCertificateExistence(userDetails.getUserPk());
    }

    @PostMapping("/cert/issue")
    public CertResponseDto issueCertificate(@RequestBody ClientCertIssueRequestDto clientCertIssueRequestDto,
                                            @AuthenticationPrincipal CustomUserDetails userDetails) {
        return userService.issueCertificate(clientCertIssueRequestDto, userDetails.getUserPk());
    }

    @GetMapping("/integrated-status")
    public Boolean checkIntegratedStatus(@AuthenticationPrincipal CustomUserDetails userDetails) {
        return userService.isIntegratedAuthenticated(userDetails.getUserPk());
    }

    @PostMapping("/digital-signature")
    public DigitalSignatureIssueResponseDto issueDigitalSignature(@RequestBody ClientDigitalSignatureRequestDto digitalSignatureIssueRequestDto,
                                                                  @AuthenticationPrincipal CustomUserDetails userDetails) {
        return userService.issueDigitalSignature(digitalSignatureIssueRequestDto, userDetails.getUserPk());
    }
}
