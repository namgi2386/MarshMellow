package com.gbh.gbh_mm.ai.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.gbh.gbh_mm.common.exception.CustomException;
import com.gbh.gbh_mm.common.exception.ErrorCode;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ClassPathResource;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.*;
import java.nio.charset.StandardCharsets;
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

        String pythonPath = "python3";
        String scriptPath;

        try (InputStream scriptStream = getClass().getClassLoader().getResourceAsStream(aiFilePath + "/categoryClf/clfModel.py")) {
            if (scriptStream == null) {
                throw new IOException("Python script not found in resources: " + aiFilePath + "/categoryClf/clfModel.py");
            }

            // ✅ 파일을 일시적으로 저장하여 경로 획득
            File tempFile = File.createTempFile("clfModel", ".py");
            try (OutputStream outputStream = new FileOutputStream(tempFile)) {
                byte[] buffer = new byte[1024];
                int bytesRead;
                while ((bytesRead = scriptStream.read(buffer)) != -1) {
                    outputStream.write(buffer, 0, bytesRead);
                }
            }
            scriptPath = tempFile.getAbsolutePath();
            System.out.println("scriptPath: " + scriptPath);
        } catch (IOException e) {
            throw new RuntimeException("Python script loading failed.", e);
        }
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
}
