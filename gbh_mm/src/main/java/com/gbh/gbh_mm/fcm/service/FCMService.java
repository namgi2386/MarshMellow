package com.gbh.gbh_mm.fcm.service;

import com.gbh.gbh_mm.fcm.repo.request.RequestFCMSend;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import org.springframework.stereotype.Service;


@Service
public class FCMService {

    public String sendNotification(RequestFCMSend requestFCMSend) throws FirebaseMessagingException {
        try {

            Message message = Message.builder()
                    .setToken(requestFCMSend.getToken())
                    .setNotification(Notification.builder()
                            .setTitle(requestFCMSend.getTitle())
                            .setBody(requestFCMSend.getBody())
                            .build())
                    .putData("key1", "value1") // 선택 사항
                    .build();

            System.out.println("✅ Successfully sent message: \" + response");
            return FirebaseMessaging.getInstance().send(message);

        } catch (FirebaseMessagingException e) {
            e.printStackTrace();
            return "❌ Error sending FCM: " + e.getMessage();
        }
    }
}
