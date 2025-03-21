package com.gbh.gbh_mm.user.config;//package com.gbh.gbh_mm.user.config;
//
//import com.google.auth.oauth2.GoogleCredentials;
//import com.google.api.services.gmail.GmailScopes;
//import org.springframework.beans.factory.annotation.Value;
//import org.springframework.context.annotation.Bean;
//import org.springframework.context.annotation.Configuration;
//import org.springframework.core.io.Resource;
//import java.util.List;
//import java.io.IOException;
//
//@Configuration
//public class GoogleAuthConfig {
//
//    @Value("${google.credentials.file}")
//    private Resource credentialsFile;
//
//    @Bean
//    public GoogleCredentials googleCredentials() throws IOException {
//        return GoogleCredentials.fromStream(credentialsFile.getInputStream())
//                .createScoped(List.of(GmailScopes.GMAIL_MODIFY));
//    }
//}