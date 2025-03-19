package com.gbh.gbh_mm.finance.card.vo.request;

import lombok.Data;

@Data
public class RequestFindBilling {
    private String userKey;
    private String cardNo;
    private String cvc;
    private String startMonth;
    private String endMonth;
}
