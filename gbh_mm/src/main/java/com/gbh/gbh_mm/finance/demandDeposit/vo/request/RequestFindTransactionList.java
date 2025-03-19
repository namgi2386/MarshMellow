package com.gbh.gbh_mm.finance.demandDeposit.vo.request;

import lombok.Data;

@Data
public class RequestFindTransactionList {
    private String accountNo;
    private String startDate;
    private String endDate;
    private String transactionType;
    private String orderByType;
    private String userKey;
}
