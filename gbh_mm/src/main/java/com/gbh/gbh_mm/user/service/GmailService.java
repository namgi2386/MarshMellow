package com.gbh.gbh_mm.user.service;//package com.gbh.gbh_mm.user.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.api.client.googleapis.auth.oauth2.GoogleCredential;
import com.google.api.client.googleapis.javanet.GoogleNetHttpTransport;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.jackson2.JacksonFactory;
import com.google.api.services.gmail.Gmail;
import com.google.api.services.gmail.model.*;
import com.google.auth.oauth2.GoogleCredentials;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.math.BigInteger;
import java.util.Collections;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class GmailService {

    private Gmail gmail;

    @Value("${google.client-id}")
    private String clientId;

    @Value("${google.client-secret}")
    private String clientSecret;

    @Value("${google.refresh-token}")
    private String refreshToken;

    @Value("${google.project-id}")
    private String projectId;

    @Value("${google.pubsub-topic}")
    private String pubSubTopic;

    @PostConstruct
    public void init() {
        try {
            GoogleCredential credential = new GoogleCredential.Builder()
                    .setTransport(GoogleNetHttpTransport.newTrustedTransport())
                    .setJsonFactory(JacksonFactory.getDefaultInstance())
                    .setClientSecrets(clientId, clientSecret)
                    .build()
                    .setRefreshToken(refreshToken);

            // access_token 자동 갱신
            credential.refreshToken();

            this.gmail = new Gmail.Builder(
                    GoogleNetHttpTransport.newTrustedTransport(),
                    JacksonFactory.getDefaultInstance(),
                    credential
            )
                    .setApplicationName("My Gmail Notifier")
                    .build();

            System.out.println("✅ Gmail client initialized");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void startWatch() throws IOException {
        String topicName = String.format("projects/%s/topics/%s", projectId, pubSubTopic);

        WatchRequest watchRequest = new WatchRequest()
                .setTopicName(topicName)
                .setLabelIds(Collections.singletonList("INBOX"));

        WatchResponse response = gmail.users().watch("me", watchRequest).execute();

        System.out.println("✅ Gmail watch started! History ID: " + response.getHistoryId());
    }

    public void restartWatch() {
        try {
            // 기존 watch 제거
            gmail.users().stop("me").execute();
            log.info("🛑 기존 Gmail watch 중단됨");

            // 새로 watch 등록
            startWatch();

        } catch (IOException e) {
            log.error("❌ Gmail watch 재등록 실패", e);
        }
    }
    public void fetchLatestEmailFromHistory(String json) {
        try {
            ObjectMapper objectMapper = new ObjectMapper();
            Map<String, Object> map = objectMapper.readValue(json, Map.class);

            String historyIdStr = (String) map.get("historyId");
            BigInteger historyId = new BigInteger(historyIdStr);

            ListHistoryResponse response = gmail.users().history().list("me")
                    .setStartHistoryId(historyId)
                    .execute();

            if (response.getHistory() == null) return;

            for (History h : response.getHistory()) {
                List<HistoryMessageAdded> added = h.getMessagesAdded();
                if (added != null) {
                    for (HistoryMessageAdded addedMsg : added) {
                        Message msg = gmail.users().messages().get("me", addedMsg.getMessage().getId()).execute();
                        String subject = getHeader(msg, "Subject");
                        System.out.println("💌 새 메일: " + subject);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    private String getHeader(Message message, String name) {
        return message.getPayload().getHeaders().stream()
                .filter(h -> h.getName().equalsIgnoreCase(name))
                .map(MessagePartHeader::getValue)
                .findFirst()
                .orElse("(no header)");
    }
}

