package com.gbh.gbh_mm.alert;

import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import org.springframework.stereotype.Service;

@Service
public class AlertService {
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
}
