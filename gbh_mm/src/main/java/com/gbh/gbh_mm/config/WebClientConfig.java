package com.gbh.gbh_mm.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.reactive.function.client.WebClient;

@Configuration
public class WebClientConfig {

    public WebClient.Builder webClientBuilder() {
        return WebClient.builder();
    }
}
