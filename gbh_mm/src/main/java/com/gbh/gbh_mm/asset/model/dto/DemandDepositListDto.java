package com.gbh.gbh_mm.asset.model.dto;

import lombok.Data;

@Data
public class DemandDepositListDto {
    private String bankCode;
    private String bankName;
    private String accountNo;
    private String accountName;
    private long accountBalance;
}
