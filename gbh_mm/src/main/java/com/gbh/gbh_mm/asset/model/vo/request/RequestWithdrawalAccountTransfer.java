package com.gbh.gbh_mm.asset.model.vo.request;

import lombok.Data;

@Data
public class RequestWithdrawalAccountTransfer {
    private int withdrawalAccountId;
    private String depositAccountNo;
    private String transactionSummary;
    private long transactionBalance;
}
