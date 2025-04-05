package com.gbh.gbh_mm.fcm.controller;

import com.gbh.gbh_mm.fcm.repo.request.RequestFCMSend;
import com.gbh.gbh_mm.fcm.service.FCMService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/mm/fcm")
public class FCMController {

    private final FCMService fcmService;


//    @PostMapping("/send")
//    public String senoNotification(@RequestBody RequestFCMSend requestFCMSend) {
//        return fcmService.sendNotification(requestFCMSend);
//    }
}
