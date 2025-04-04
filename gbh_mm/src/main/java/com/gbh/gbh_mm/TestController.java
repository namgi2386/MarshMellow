//package com.gbh.gbh_mm;
//
//import com.gbh.gbh_mm.asset.ResponseAuthTest;
//import com.gbh.gbh_mm.common.dto.ChildRequestAndResponse;
//import com.gbh.gbh_mm.common.exception.CustomException;
//import com.gbh.gbh_mm.common.exception.ErrorCode;
//import java.nio.charset.StandardCharsets;
//import java.security.InvalidAlgorithmParameterException;
//import java.security.InvalidKeyException;
//import java.security.NoSuchAlgorithmException;
//import java.security.SecureRandom;
//import java.util.Base64;
//import javax.crypto.BadPaddingException;
//import javax.crypto.Cipher;
//import javax.crypto.IllegalBlockSizeException;
//import javax.crypto.KeyGenerator;
//import javax.crypto.NoSuchPaddingException;
//import javax.crypto.SecretKey;
//import javax.crypto.spec.IvParameterSpec;
//import javax.crypto.spec.SecretKeySpec;
//import org.springframework.web.bind.annotation.PostMapping;
//import org.springframework.web.bind.annotation.RequestBody;
//import org.springframework.web.bind.annotation.RequestMapping;
//import org.springframework.web.bind.annotation.RestController;
//
//@RestController
//@RequestMapping("/api/test")
//public class TestController {
//
//    @PostMapping("/child")
//    public ChildRequestAndResponse getChild(@RequestBody ChildRequestAndResponse requestAndResponse) {
//        int childId = requestAndResponse.getChildId();
//
//        // childId가 1이면 성공, 아니면 예외 발생
//        if (childId == 1) {
//            return requestAndResponse;
//        } else {
//            throw new CustomException(ErrorCode.CHILD_NOT_FOUND);
//        }
//
//    }
//
//    public void en() {
//        try {
//            KeyGenerator keyGen = KeyGenerator.getInstance("AES");
//            keyGen.init(128);
//            SecretKey key = keyGen.generateKey();
//            String encodedKey = Base64.getEncoder().encodeToString(key.getEncoded());
//
//            ResponseAuthTest response = new ResponseAuthTest();
//            response.setEncodeKey(encodedKey);
//
//            byte[] iv = new byte[16];
//            SecureRandom secureRandom = new SecureRandom();
//            secureRandom.nextBytes(iv);
//            IvParameterSpec ivParameterSpec = new IvParameterSpec(iv);
//
//            Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
//            cipher.init(Cipher.ENCRYPT_MODE, key, ivParameterSpec);
//
//            String encodedIV = Base64.getEncoder().encodeToString(iv);
//
//            response.setIv(encodedIV);
//
//            String planeText = "암호화 할 값";
//            byte[] planeBytes = cipher.doFinal(planeText.getBytes(StandardCharsets.UTF_8));
//
//            String cipherText = Base64.getEncoder().encodeToString(planeBytes);
//
//            response.setValue(cipherText);
//
//            return response;
//
//        } catch (Exception e) {
//            throw new RuntimeException(e);
//        }
//    }
//
//
//    public void de() {
//        String encodedIV = request.getIv();
//        String encodedCipherText = request.getValue();
//
//        // SecretKey는 암호화할 때 사용했던 키 (예: Base64로 인코딩된 키를 디코딩 후 SecretKeySpec 생성)
//        String base64Key = request.getKey();
//        byte[] decodedKey = Base64.getDecoder().decode(base64Key);
//        SecretKeySpec secretKeySpec = new SecretKeySpec(decodedKey, "AES");
//
//        // 1. Base64 디코딩: IV와 암호문
//        byte[] decodedIV = Base64.getDecoder().decode(encodedIV);
//        byte[] decodedCipherText = Base64.getDecoder().decode(encodedCipherText);
//
//        // 2. IV 객체 생성
//        IvParameterSpec ivParameterSpec = new IvParameterSpec(decodedIV);
//
//        try {
//
//            // 3. Cipher 초기화 (AES/CBC/PKCS5Padding 모드 사용)
//            Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
//            cipher.init(Cipher.DECRYPT_MODE, secretKeySpec, ivParameterSpec);
//
//            // 4. 복호화 수행
//            byte[] decryptedBytes = cipher.doFinal(decodedCipherText);
//            String decryptedText = new String(decryptedBytes, StandardCharsets.UTF_8);
//
//            ResponseAuthTest response = new ResponseAuthTest();
//            response.setValue(decryptedText);
//
//            return response;
//        } catch (Exception e) {
//            throw new RuntimeException(e);
//        }
//    }
//
//}