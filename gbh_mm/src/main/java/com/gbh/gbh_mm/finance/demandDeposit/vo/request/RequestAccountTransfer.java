package com.gbh.gbh_mm.finance.demandDeposit.vo.request;

import lombok.Data;

@Data
public class RequestAccountTransfer {
    private String depositAccountNo;
    private String depositTransactionSummary;
    private long transactionBalance;
    private String withdrawalAccountNo;
    private String withdrawalTransactionSummary;
    private String userKey;
}
