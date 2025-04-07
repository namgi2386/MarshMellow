package com.gbh.gbh_mm.user.controller;

import com.gbh.gbh_mm.user.service.EmitterService;
import com.gbh.gbh_mm.user.service.GmailService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.util.Base64;
import java.util.Map;

@RestController
@RequiredArgsConstructor
public class EmitterController {

    private final EmitterService emitterService;
    private final GmailService gmailService;
    @GetMapping(value ="/api/mm/auth/subscribe/{phoneNumber}", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public SseEmitter subscribe(@PathVariable String phoneNumber,
                                @RequestHeader(value = "Last-Event-ID", required = false, defaultValue = "") String lastEventId){
        return emitterService.subscribe(phoneNumber, lastEventId);
    }

    @GetMapping("/api/mm/auth/webhook")
    public boolean receiveEmail(@RequestParam String phoneNumber, @RequestParam String code, @RequestParam int currentTime){
        return emitterService.verifyEmail(phoneNumber, code, currentTime);
    }
    @PostMapping("/gmail/webhook")
    public ResponseEntity<String> receivePubSub(@RequestBody Map<String, Object> body) {
        try {
            Map<String, Object> message = (Map<String, Object>) body.get("message");
            String data = (String) message.get("data");

            String decodedJson = new String(Base64.getDecoder().decode(data));
            System.out.println("📨 받은 Pub/Sub 메시지: " + decodedJson);

            gmailService.fetchLatestEmailFromHistory(decodedJson);

            return ResponseEntity.ok("OK");

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("Webhook 처리 실패");
        }
    }
}
