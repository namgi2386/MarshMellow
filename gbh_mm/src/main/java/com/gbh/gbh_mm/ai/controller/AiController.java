package com.gbh.gbh_mm.ai.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.gbh.gbh_mm.common.exception.CustomException;
import com.gbh.gbh_mm.common.exception.ErrorCode;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.*;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("api/mm/ai")
public class AiController {

    @Value("${ai.path}")
    private String aiFilePath;

    @PostMapping("/category")
    public Map<String, Object> runCategory(@RequestBody Map<String, List<String>> payload) {
        List<String> tradeNames = payload.get("tradeNames");
        System.out.println("입력받은 상호명들: " + tradeNames);
        if (tradeNames == null || tradeNames.isEmpty()) {
            throw new CustomException(ErrorCode.BAD_REQUEST);
        }

//        String pythonPath = "/usr/bin/python3.9";
        String pythonPath = "python3";
//        String scriptPath = System.getProperty("user.dir") + aiFilePath + "/categoryClf/clfModel.py";
        String scriptPath = getPythonScriptPath();
//        System.out.println("scriptPath: " + scriptPath);
//        InputStream convertPath = getClass().getClassLoader().getResourceAsStream(aiFilePath + "/clfModel.py");
//        if (convertPath == null) {
//            throw new CustomException(ErrorCode.DATABASE_ERROR);
//        }
        System.out.println("scriptPath: " + scriptPath);

        Map<String, Object> responseMap = new HashMap<>();

        try {
            System.out.println("파이썬 실행 전");
            ProcessBuilder processBuilder = new ProcessBuilder(pythonPath, scriptPath);
            processBuilder.environment().put("PYTHONIOENCODING", "UTF-8");
            processBuilder.redirectErrorStream(false); // ✅ stderr 따로 읽기
            Process process = processBuilder.start();
            System.out.println("파이썬 실행 후");
            // ✅ Python으로 JSON 데이터 전송 (stdin 사용)
            try (BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(process.getOutputStream(), StandardCharsets.UTF_8))) {
                ObjectMapper objectMapper = new ObjectMapper();
                writer.write(objectMapper.writeValueAsString(payload));
                writer.flush();
            }

            // ✅ Python stdout 읽기
            BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream(), StandardCharsets.UTF_8));
            StringBuilder output = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                output.append(line);
            }
            System.out.println(output.toString());
            // ✅ Python stderr 읽기 (오류 메시지)
            BufferedReader errorReader = new BufferedReader(new InputStreamReader(process.getErrorStream(), StandardCharsets.UTF_8));
            StringBuilder errorOutput = new StringBuilder();
            while ((line = errorReader.readLine()) != null) {
                errorOutput.append(line).append("\n");
            }

            int exitCode = process.waitFor();
            if (exitCode == 0) {
                try {
                    // ✅ JSON 변환
                    ObjectMapper objectMapper = new ObjectMapper();
                    Map<String, Object> jsonResponse = objectMapper.readValue(output.toString(), Map.class);
                    responseMap.put("status", jsonResponse.getOrDefault("status", "error"));
                    responseMap.put("data", jsonResponse);
                } catch (Exception e) {
                    responseMap.put("status", "error");
                    responseMap.put("message", "Invalid JSON response: " + output.toString());
                }
            } else {
                responseMap.put("status", "error");
                responseMap.put("message", "Python script execution failed.");
                responseMap.put("error_details", errorOutput.toString().trim()); // ✅ stderr 출력
            }

        } catch (IOException | InterruptedException e) {
            responseMap.put("status", "error");
            responseMap.put("message", e.getMessage());
        }

        return responseMap;
    }
    public static String getPythonScriptPath() {
        try {
            // 1️⃣ JAR 내부의 파일을 InputStream으로 가져옴
            InputStream inputStream = AiController.class.getClassLoader().getResourceAsStream("clfModel.py");
            if (inputStream == null) {
                System.out.println("No inputStream");
                throw new CustomException(ErrorCode.BAD_REQUEST);
            }

            // 2️⃣ 임시 파일 생성
            File tempFile = File.createTempFile("clfModel", ".py");
            tempFile.deleteOnExit(); // 프로그램 종료 시 자동 삭제

            // 3️⃣ InputStream 데이터를 임시 파일로 저장
            Files.copy(inputStream, tempFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
            inputStream.close();

            return tempFile.getAbsolutePath(); // 🏆 Python 실행 가능한 파일 경로 반환
        } catch (IOException e) {
            throw new CustomException(ErrorCode.BAD_REQUEST);
        }
    }
}
