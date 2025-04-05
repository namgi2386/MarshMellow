package com.gbh.gbh_mm.fcm.service;

import com.gbh.gbh_mm.fcm.model.request.RequestFCMSend;
import com.google.firebase.messaging.*;
import org.springframework.stereotype.Service;

import java.util.concurrent.ExecutionException;


@Service
public class FCMService {

    // 실제 값 넣어서 알림
    public String sendNotification(RequestFCMSend requestFCMSend) throws InterruptedException, ExecutionException {
        Message message = Message.builder()
                .setToken(requestFCMSend.getToken())
                .setNotification(Notification.builder()
                        .setTitle(requestFCMSend.getTitle())
                        .setBody(requestFCMSend.getBody())
                        .build())
                .setAndroidConfig(AndroidConfig.builder()
                        .setPriority(AndroidConfig.Priority.HIGH)
                        .build())
                .build();
        String response = FirebaseMessaging.getInstance().sendAsync(message).get();
        System.out.println("✅ Successfully sent message: " + response);
        return response;

    }
    // AlertService -> fcmService
    public String sendNotification(Message message) throws InterruptedException, ExecutionException {
        String response = FirebaseMessaging.getInstance().sendAsync(message).get();
        System.out.println("✅ Successfully sent message: " + response);
        return response;

    }
}
