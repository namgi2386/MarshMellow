package com.gbh.gbh_mm.finance.auth.vo.request;

import lombok.Data;

@Data
public class RequestCheckAccountAuth {
    private String userKey;
    private String accountNo;
    private String authCode;
}
