package com.gbh.gbh_mm.asset.model.dto;

import lombok.Data;

@Data
public class DepositListDto {
    private String bankCode;
    private String bankName;
    private String accountNo;
    private String accountName;
    private long depositBalance;
}
