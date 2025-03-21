package com.gbh.gbh_mm.asset.model.entity;

import lombok.Data;

@Data
public class Card {
    private String cardNo;
    private String cvc;
    private String cardUniqueNo;
    private String cardIssuerCode;
    private String cardIssuerName;
    private String cardName;
    private long baselinePerformance;
    private long maxBenefitLimit;
    private String cardDescription;
    private String cardExpiryDate;
    private String withdrwalAccountNo;
    private String withdrwalDate;
}
