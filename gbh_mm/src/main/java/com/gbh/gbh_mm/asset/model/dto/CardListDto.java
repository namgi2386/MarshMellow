package com.gbh.gbh_mm.asset.model.dto;

import lombok.Data;

@Data
public class CardListDto {
    private String cardNo;
    private String cvc;
    private String cardIssuerCode;
    private String cardIssuerName;
    private String cardName;
}
