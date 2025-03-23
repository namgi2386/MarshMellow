package com.gbh.gbh_mm.user.service;

import com.gbh.gbh_mm.user.model.request.IdentityVerificationRequestDto;
import com.gbh.gbh_mm.user.model.response.IdentityVerificationResponseDto;
import com.gbh.gbh_mm.user.repo.EmitterRepository;
import com.gbh.gbh_mm.user.repo.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.security.SecureRandom;
import java.time.Duration;

@Service
@Slf4j
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
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

}
