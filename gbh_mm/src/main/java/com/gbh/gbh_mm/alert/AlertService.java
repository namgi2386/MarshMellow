package com.gbh.gbh_mm.alert;

import com.gbh.gbh_mm.budget.model.response.ResponseFindDailyBudget;
import com.gbh.gbh_mm.budget.service.BudgetService;
import com.gbh.gbh_mm.fcm.service.FCMService;
import com.gbh.gbh_mm.user.model.entity.User;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.concurrent.ExecutionException;

@Service
@RequiredArgsConstructor
public class AlertService {

    private final BudgetService budgetService;
    private final FCMService fcmService;

    public void sendNotification(String token, String title, String body) {
        Notification noti = Notification.builder()
                .setTitle(title)
                .setBody(body)
                .build();

        Message message = Message.builder()
                .setToken(token)
                .setNotification(noti)
                .build();

        try {
            String response = FirebaseMessaging.getInstance().send(message);
            System.out.println(response);
        } catch (FirebaseMessagingException e) {
            e.printStackTrace();
        }
    }

    // 오늘의 예산 알림
    public void sendBudgetNotification(User user) throws InterruptedException, ExecutionException {
        ResponseFindDailyBudget dailyBudget =  budgetService.getDailyBudget(user.getUserPk());
        String remainBudgetAmount = String.format("%,d", dailyBudget.getRemainBudgetAmount());
        String dailyBudgetAmount = String.format("%,d", dailyBudget.getDailyBudgetAmount());
        Notification noti = Notification.builder()
                .setTitle("오늘의 예산")
                .setBody("이번 달 남은 예산 " + remainBudgetAmount + " 원!" + "오늘은 " + dailyBudgetAmount + " 원까지만 써 보세요.")
                .build();

        Message message = Message.builder()
                .setToken(user.getFcmToken())
                .setNotification(noti)
                .build();

        System.out.println(fcmService.sendNotification(message));
    }
}
