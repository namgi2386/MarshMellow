package com.gbh.gbh_mm.asset.model.dto;

import lombok.Data;

@Data
public class SavingsListDto {
    private String bankCode;
    private String bankName;
    private String accountNo;
    private String accountName;
    private long totalBalance;
}
