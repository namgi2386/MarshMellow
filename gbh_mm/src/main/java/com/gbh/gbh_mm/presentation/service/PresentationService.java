package com.gbh.gbh_mm.presentation.service;

import com.gbh.gbh_mm.alert.AlertService;
import com.gbh.gbh_mm.fcm.service.FCMService;
import com.gbh.gbh_mm.presentation.request.RequestSendAlert;
import com.gbh.gbh_mm.user.model.entity.User;
import com.gbh.gbh_mm.user.repo.UserRepository;
import com.gbh.gbh_mm.user.service.UserService;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@AllArgsConstructor
public class PresentationService {

    private final UserRepository userRepository;

    private final AlertService alertService;

    public String sendAlert(RequestSendAlert request) {

        try {
            User user = userRepository.findByUserPk(request.getUserPk())
                .orElseThrow(() -> new RuntimeException("User Not Found"));

            String fcmToken = user.getFcmToken();
            String title = "월급 알림";
            String message = user.getUserName() + "님! 오늘은 월급날이에요! 월 예산을 확인해볼까요 :)";
            alertService.sendNotification(fcmToken, title, message);

            return "SUCCESS";
        } catch (Exception e) {
            e.printStackTrace();

            return "FAIL";
        }
    }
}
