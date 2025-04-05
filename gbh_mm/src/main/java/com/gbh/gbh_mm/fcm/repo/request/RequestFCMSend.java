package com.gbh.gbh_mm.fcm.repo.request;

import lombok.Data;

@Data
public class RequestFCMSend {
    private String token;

    private String title;

    private String body;

}
