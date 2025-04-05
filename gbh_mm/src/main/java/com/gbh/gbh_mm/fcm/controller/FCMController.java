package com.gbh.gbh_mm.fcm.controller;


import com.gbh.gbh_mm.alert.AlertService;
import com.gbh.gbh_mm.fcm.model.request.RequestFCMSend;
import com.gbh.gbh_mm.fcm.service.FCMService;
import com.gbh.gbh_mm.user.model.entity.CustomUserDetails;
import com.gbh.gbh_mm.user.repo.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.concurrent.ExecutionException;

@RestController
@RequiredArgsConstructor
@RequestMapping("/mm/fcm")
public class FCMController {

    private final FCMService fcmService;
    private final AlertService alertService;
    private final UserRepository userRepository;

    @PostMapping("/send")
    public String senoNotification(@RequestBody RequestFCMSend requestFCMSend) throws ExecutionException, InterruptedException {
        return fcmService.sendNotification(requestFCMSend);
    }

    @GetMapping("/test/dailybudget")
    public void testDailyBudget(@AuthenticationPrincipal CustomUserDetails userDetails) throws ExecutionException, InterruptedException {
        alertService.sendBudgetNotification(userRepository.findByUserPk(userDetails.getUserPk()).get());
    }
}
