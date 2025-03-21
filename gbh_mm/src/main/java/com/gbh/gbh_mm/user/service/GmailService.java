package com.gbh.gbh_mm.user.service;//package com.gbh.gbh_mm.user.service;
//
//import com.google.api.client.googleapis.auth.oauth2.GoogleCredential;
//import com.google.api.client.http.javanet.NetHttpTransport;
//import com.google.api.client.json.jackson2.JacksonFactory;
//import com.google.api.services.gmail.Gmail;
//import com.google.api.services.gmail.model.WatchRequest;
//import com.google.api.services.gmail.model.WatchResponse;
//import com.google.auth.oauth2.GoogleCredentials;
//import lombok.RequiredArgsConstructor;
//import lombok.extern.slf4j.Slf4j;
//import org.springframework.beans.factory.annotation.Value;
//import org.springframework.stereotype.Service;
//
//import java.io.IOException;
//import java.util.List;
//
//@Service
//@RequiredArgsConstructor
//@Slf4j
//public class GmailService {
//
//    private final GoogleCredentials googleCredentials;
//
//    @Value("${google.project-id}")
//    private String projectId;
//
//    @Value("${google.pub sub-topic}")
//    private String pubSubTopic;
//
//    public void startWatch() throws IOException {
//        Gmail gmail = new Gmail.Builder(new NetHttpTransport(), new JacksonFactory(), googleCredentials)
//                .setApplicationName("MyApp")
//                .build();
//
//        WatchRequest watchRequest = new WatchRequest()
//                .setLabelIds(List.of("INBOX"))  // 받은 편지함(INBOX)만 감지
//                .setTopicName(pubSubTopic);
//
//        WatchResponse response = gmail.users().watch("me", watchRequest).execute();
//
//        log.info("✅ Gmail Watch 설정 완료 (7일 동안 유효)");
//        log.info("📌 현재 historyId: {}", response.getHistoryId());
//        log.info("📌 만료 시간 (밀리초): {}", response.getExpiration());
//    }
//
//    public void stopWatch() throws IOException {
//        Gmail gmail = new Gmail.Builder(new NetHttpTransport(), new JacksonFactory(), googleCredentials)
//                .setApplicationName("MyApp")
//                .build();
//
//        gmail.users().stop("me").execute();
//        log.info("⛔ Gmail Watch 중지됨");
//    }
//
//}
//
