package com.gbh.gbh_mm.finance.card.vo.request;

import lombok.Data;

@Data
public class RequestFindCardTransactionList {
    private String userKey;
    private String cardNo;
    private String cvc;
    private String startDate;
    private String endDate;
}
