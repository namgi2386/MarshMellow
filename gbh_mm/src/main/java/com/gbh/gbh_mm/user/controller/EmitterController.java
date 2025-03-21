package com.gbh.gbh_mm.user.controller;

import com.gbh.gbh_mm.user.service.EmitterService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

@RestController
@RequiredArgsConstructor
public class EmitterController {

    private final EmitterService emitterService;

    @GetMapping(value ="/api/mm/auth/subscribe/{phoneNumber}", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public SseEmitter subscribe(@RequestParam String phoneNumber,
                                @RequestHeader(value = "Last-Event-ID", required = false, defaultValue = "") String lastEventId){
        return emitterService.subscribe(phoneNumber, lastEventId);
    }

    @GetMapping("/api/mm/auth/webhook")
    public boolean receiveEmail(@RequestParam String phoneNumber, @RequestParam String code, @RequestParam int currentTime){
        return emitterService.verifyEmail(phoneNumber, code, currentTime);
    }

}
