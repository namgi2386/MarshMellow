package com.gbh.gbh_mm.user.service;

import com.gbh.gbh_mm.common.exception.CustomException;
import com.gbh.gbh_mm.common.exception.ErrorCode;
import com.gbh.gbh_mm.user.model.entity.User;
import com.gbh.gbh_mm.user.model.request.IdentityVerificationRequestDto;
import com.gbh.gbh_mm.user.model.request.LoginByBioRequestDto;
import com.gbh.gbh_mm.user.model.request.LoginByPinRequestDto;
import com.gbh.gbh_mm.user.model.request.SignUpRequestDto;
import com.gbh.gbh_mm.user.model.response.IdentityVerificationResponseDto;
import com.gbh.gbh_mm.user.model.response.LoginResponseDto;
import com.gbh.gbh_mm.user.model.response.SignUpResponseDto;
import com.gbh.gbh_mm.user.repo.UserRepository;
import com.gbh.gbh_mm.user.util.JwtTokenProvider;
import com.gbh.gbh_mm.user.util.RSAUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.time.Duration;
import java.util.Date;
import java.util.HashMap;
import java.util.Objects;
import java.util.concurrent.TimeUnit;

@Service
@Slf4j
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final BCryptPasswordEncoder bCryptPasswordEncoder;
    private final JwtTokenProvider jwtTokenProvider;
    private final RedisTemplate<String, Object> redisTemplate;
    private final SecureRandom secureRandom = new SecureRandom();
    @Value("${spring.mail.username}")
    private String serverEmail;

    public IdentityVerificationResponseDto verify(IdentityVerificationRequestDto identityVerificationRequestDto) {
        String phoneNumber = identityVerificationRequestDto.getPhoneNumber();
        String verificationCode = generateVerificationCode();
        int ttlTimes = 3;
        IdentityVerificationResponseDto identityVerificationResponseDto = IdentityVerificationResponseDto.
                builder()
                .serverEmail(serverEmail)
                .code(verificationCode)
                .verified(false)
                .expiresIn(ttlTimes * 60)
                .build();
        redisTemplate.opsForValue().set(phoneNumber, identityVerificationResponseDto, Duration.ofMinutes(ttlTimes));
        log.info("Redis에 인증 코드 저장: key={}, value={}, 만료시간=3분", phoneNumber, identityVerificationResponseDto);
        return identityVerificationResponseDto;
    }

    private String generateVerificationCode() {
        int code = secureRandom.nextInt(900000) + 100000; // 6자리 인증번호 생성 (100000 ~ 999999)
        return String.valueOf(code);
    }

    @Transactional
    public SignUpResponseDto register(SignUpRequestDto signUpRequestDto) {

        // 중복회원 검증을 핸드폰 번호로 해버리면~~~? -> 번호이동 -> 새로 회원가입해야함?
        if (userRepository.existsByPhoneNumber(signUpRequestDto.getPhoneNumber())) {
            throw new CustomException(ErrorCode.DUPLICATE_RESOURCE);
        }
        String userCode = signUpRequestDto.getUserCode();
        if (Objects.isNull(userCode) || !userCode.matches("\\d{6}-[1-4]")) {
            throw new CustomException(ErrorCode.VALIDATION_FAILED);
        }

        String birthDate = userCode.substring(0, 6);
        char gender = userCode.charAt(7);
        if (gender == '1' || gender == '3') {
            gender = 'M';
        } else if (gender == '2' || gender == '4') {
            gender = 'F';
        }

        // RSAKey 생성
        HashMap<String, String> keyPair = RSAUtil.generateKeyPair();
        String publicKey = keyPair.get("publicKey");
        String privateKey = keyPair.get("privateKey");

        User user = User.builder()
                .userName(signUpRequestDto.getUserName())
                .userEmail(signUpRequestDto.getUserEmail())
                .phoneNumber(signUpRequestDto.getPhoneNumber())
                .birth(birthDate)
                .gender(gender)
                .pin(bCryptPasswordEncoder.encode(signUpRequestDto.getPin()))
                .build();
        userRepository.save(user);
        String accessToken = jwtTokenProvider.createAccessToken(user.getUserPk());
        String refreshToken = jwtTokenProvider.createRefreshToken(user.getUserPk());

        return SignUpResponseDto.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .build();
    }

    public LoginResponseDto loginByPin(LoginByPinRequestDto loginByPinRequestDto) {

        // 회원 조회
        User user = userRepository.findByPhoneNumber(loginByPinRequestDto.getPhoneNumber())
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        // pin 검증
        if (!bCryptPasswordEncoder.matches(loginByPinRequestDto.getPin(), user.getPin())) {
            throw new CustomException(ErrorCode.USER_INVALID_PIN);
        }

        String accessToken = jwtTokenProvider.createAccessToken(user.getUserPk());
        String refreshToken = jwtTokenProvider.createRefreshToken(user.getUserPk());
        return LoginResponseDto.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .build();
    }

    public LoginResponseDto loginByBio(LoginByBioRequestDto loginByBioRequestDto) {
        // 회원 조회
        User user = userRepository.findByPhoneNumber(loginByBioRequestDto.getPhoneNumber())
                .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));
        String accessToken = jwtTokenProvider.createAccessToken(user.getUserPk());
        String refreshToken = jwtTokenProvider.createRefreshToken(user.getUserPk());
        return LoginResponseDto.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .build();
    }
    public LoginResponseDto reissueTokens(String refreshToken) {
        // (1) refreshToken 유효성 검사
        if (!jwtTokenProvider.isRefreshTokenValid(refreshToken)) {
            throw new CustomException(ErrorCode.INVALID_TOKEN);
        }
        // (2) userPk 추출
        String userPk = jwtTokenProvider.getUserPk(refreshToken);

        // (3) 새 토큰 발급
        String newAccessToken = jwtTokenProvider.createAccessToken(Long.valueOf(userPk));
        String newRefreshToken = jwtTokenProvider.createRefreshToken(Long.valueOf(userPk));

        // (4) 응답
        return LoginResponseDto.builder()
                .accessToken(newAccessToken)
                .refreshToken(newRefreshToken)
                .build();
    }

    // == 로그아웃(Access Token 블랙리스트 등록, Refresh Token 삭제) ==
    public void logout(String bearerToken) {

        String accessToken = "";

        if(Objects.nonNull(bearerToken) && bearerToken.startsWith("Bearer ")){
            accessToken = bearerToken.substring(7);
        }
        // 만료까지 남은 시간 계산
        long expiration = getRemainingExpiration(accessToken);

        // Access Token 블랙리스트 등록
        if (expiration > 0) {
            redisTemplate.opsForValue().set("BL:" + accessToken, "true", expiration, TimeUnit.MILLISECONDS);
        }
        // Refresh Token 삭제
        String userPk = jwtTokenProvider.getUserPk(accessToken);
        redisTemplate.delete("RT:" + userPk);
    }

    /**
     * 안전하게 AT 남은 만료 시간을 구하는 헬퍼 (파싱 예외 방지)
     */
    private long getRemainingExpiration(String accessToken) {
        try {
            Date expiration = jwtTokenProvider.extractExpiration(accessToken);
            long now = System.currentTimeMillis();
            return expiration.getTime() - now;
        } catch (Exception e) {
            // 파싱 불가 또는 이미 만료된 경우
            return 0;
        }
    }

    public Boolean isIntegratedAuthenticated(Long userPk) {
        User user = userRepository.findByUserPk(userPk)
                .orElseThrow(() -> new RuntimeException("사용자를 찾을 수 없습니다."));
        return !Objects.isNull(user.getUserKey());
    }
}
