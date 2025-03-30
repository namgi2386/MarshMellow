package com.gbh.gbh_cert.service;

import com.gbh.gbh_cert.api.UserAPI;
import com.gbh.gbh_cert.global.exception.CustomException;
import com.gbh.gbh_cert.global.exception.ErrorCode;
import com.gbh.gbh_cert.model.dto.request.CIRequestDto;
import com.gbh.gbh_cert.model.dto.request.CertExistRequestDto;
import com.gbh.gbh_cert.model.dto.request.CertIssueRequestDto;
import com.gbh.gbh_cert.model.dto.request.RequestCreateUserKey;
import com.gbh.gbh_cert.model.dto.response.CIResponseDto;
import com.gbh.gbh_cert.model.dto.response.CertExistResponseDto;
import com.gbh.gbh_cert.model.dto.response.CertResponseDto;
import com.gbh.gbh_cert.model.entity.Certificate;
import com.gbh.gbh_cert.model.entity.User;
import com.gbh.gbh_cert.model.repository.CertficateRepository;
import com.gbh.gbh_cert.util.CIGenerator;
import lombok.RequiredArgsConstructor;
import org.bouncycastle.asn1.pkcs.PrivateKeyInfo;
import org.bouncycastle.asn1.x500.X500Name;
import org.bouncycastle.cert.jcajce.JcaX509CertificateConverter;
import org.bouncycastle.cert.jcajce.JcaX509v3CertificateBuilder;
import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.bouncycastle.openssl.PEMParser;
import org.bouncycastle.openssl.jcajce.JcaPEMKeyConverter;
import org.bouncycastle.openssl.jcajce.JcaPEMWriter;
import org.bouncycastle.operator.ContentSigner;
import org.bouncycastle.operator.jcajce.JcaContentSignerBuilder;
import org.bouncycastle.pkcs.PKCS10CertificationRequest;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.*;
import java.math.BigInteger;
import java.security.KeyPair;
import java.security.PrivateKey;
import java.security.Security;
import java.security.cert.X509Certificate;
import java.util.*;

@Service
@RequiredArgsConstructor
public class CertService {

    private final CIGenerator ciGenerator;
    private final UserService userService;
    private final CertficateRepository certficateRepository;

    @Value("${cert.ca-private-key}")
    private Resource caPrivateKeyResource;

    @Transactional
    public CIResponseDto getConnectionInformation(CIRequestDto ciRequestDto) {
        String ci = ciGenerator.generateCi(ciRequestDto);

        userService.registerUserIfNotExist(ciRequestDto, ci);

        return CIResponseDto.builder()
                .connectionInformation(ci)
                .build();
    }
    @Transactional
    public CertResponseDto createCertificate(CertIssueRequestDto certIssueRequestDto) throws Exception {
        String rawCsrPem = certIssueRequestDto.getCsrPem();
        System.out.println(">>> Raw CSR PEM: [" + rawCsrPem + "]");

        // 2. CSR PEM 문자열 정리: 캐리지 리턴 제거, 이스케이프된 줄바꿈 변환, 앞뒤 공백 제거
        String csrPem = rawCsrPem
                .replace("\r", "")
                .replace("\\n", "\n")
                .trim();

        // 3. 헤더/푸터 검증
        if (!csrPem.startsWith("-----BEGIN CERTIFICATE REQUEST-----") ||
                !csrPem.endsWith("-----END CERTIFICATE REQUEST-----")) {
            throw new IllegalArgumentException("Invalid CSR format");
        }

        // 4. 헤더와 푸터를 제거하여 Base64 데이터만 추출 후 모든 공백 제거
        String base64Data = csrPem
                .replace("-----BEGIN CERTIFICATE REQUEST-----", "")
                .replace("-----END CERTIFICATE REQUEST-----", "")
                .replaceAll("\\s+", "").trim();

        byte[] decodedBytes = java.util.Base64.getDecoder().decode(base64Data);
        PKCS10CertificationRequest csr = new PKCS10CertificationRequest(decodedBytes);

        // 보안 프로바이더 설정
        Security.addProvider(new BouncyCastleProvider());

        // 2. 발급자 (CA) 정보 설정
        //인증 기관(CA)의 세부 정보를 설정합니다.
        //현재 타임스탬프를 사용하여 고유한 일련번호를 생성합니다.
        //인증서 유효 기간을 현재 시간부터 1년 후로 설정합니다.
        X500Name issuer = new X500Name("CN=MM CA,O=MyCA,C=KR");
        BigInteger serial = BigInteger.valueOf(System.currentTimeMillis());
        Date notBefore = new Date();
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.YEAR, 1);
        Date notAfter = cal.getTime();

        // 3. 인증서 생성
        // X.509 v3 인증서를 생성합니다.
        //CA의 개인키로 인증서에 서명합니다.
        //SHA256withRSA 서명 알고리즘을 사용합니다.
        JcaX509v3CertificateBuilder certBuilder = new JcaX509v3CertificateBuilder(
                issuer, serial, notBefore, notAfter, csr.getSubject(), csr.getSubjectPublicKeyInfo());

        ContentSigner signer = new JcaContentSignerBuilder("SHA512withRSA")
                .build(loadCaPrivateKey()); // 너의 CA 개인키를 불러오는 메서드 필요

        X509Certificate x509Certificateertificate = new JcaX509CertificateConverter()
                .setProvider("BC").getCertificate(certBuilder.build(signer));

        // CI로 유저 조회
        User user = userService.lookUpUserByCI(certIssueRequestDto.getConnectionInformation());

        // userKey 생성 및 반 저장 후 반 리턴
        String halfUserKey = userService.updateUserKey(user, certIssueRequestDto.getUserEmail());

        Certificate certificate = Certificate.builder()
                .user(user)
                .certSerial(x509Certificateertificate.getSerialNumber().longValue())
                .certData(convertCertificateToPem(x509Certificateertificate)) // 문자열로 저장
                .certStatus(Certificate.CertStatus.VALID)
                .build();

        certficateRepository.findByUser(user)
                .ifPresent(cert -> {
                    cert.setCertStatus(Certificate.CertStatus.EXPIRED);
                    certficateRepository.save(cert);
                });

        certficateRepository.save(certificate);

        // 5. PEM 인코딩 후 반환
        StringWriter writer = new StringWriter();
        JcaPEMWriter pemWriter = new JcaPEMWriter(writer);
        pemWriter.writeObject(x509Certificateertificate);
        pemWriter.close();
        return CertResponseDto.builder()
                .certificatePem(writer.toString())
                .halfUserKey(halfUserKey)
                .build();
    }

    private PrivateKey loadCaPrivateKey() throws Exception {
        // 예: src/main/resources/ca/ca_private_key.pem
        // 여기선 간단하게 KeyStore, 또는 파일 기반 PEM 파싱으로 구현 가능
        try (InputStream inputStream = caPrivateKeyResource.getInputStream();
             PEMParser pemParser = new PEMParser(new InputStreamReader(inputStream))) {

            Object keyObject = pemParser.readObject();
            JcaPEMKeyConverter converter = new JcaPEMKeyConverter();

            // PrivateKeyInfo 또는 KeyPair 타입 처리
            if (keyObject instanceof PrivateKeyInfo) {
                return converter.getPrivateKey((PrivateKeyInfo) keyObject);
            } else if (keyObject instanceof KeyPair) {
                return ((KeyPair) keyObject).getPrivate();
            }

            throw new IllegalArgumentException("지정된 키 형식이 아닙니다.");
        }
    }

    // PEM 형식으로 인증서 변환
    private String convertCertificateToPem(X509Certificate certificate) {
        try (StringWriter writer = new StringWriter();
             JcaPEMWriter pemWriter = new JcaPEMWriter(writer)) {
            pemWriter.writeObject(certificate);
            pemWriter.flush();
            return writer.toString();
        } catch (IOException e) {
            throw new RuntimeException("Certificate PEM conversion failed", e);
        }
    }

    public CertExistResponseDto checkCertificateExistence(CertExistRequestDto certExistRequestDto) {
        User user = userService.lookUpUserByCI(certExistRequestDto.getConnectionInformation());
        System.out.println(">>> [User] ID: " + user.getUserId());
        Optional<Certificate> certOpt = certficateRepository.findByUserAndCertStatus(user, Certificate.CertStatus.VALID);

        certOpt.ifPresent(cert -> System.out.println(">>> [Cert] ID: " + cert.getCertId()));

        if (certOpt.isPresent()) {
            System.out.println("exist yes");
            Certificate cert = certOpt.get();
            return CertExistResponseDto.builder()
                    .exist(true)
                    .status(cert.getCertStatus().name())
                    .certificatePem(cert.getCertData())
                    .build();
        } else {
            System.out.println("exist no");
            return CertExistResponseDto.builder()
                    .exist(false)
                    .build();
        }
    }
}