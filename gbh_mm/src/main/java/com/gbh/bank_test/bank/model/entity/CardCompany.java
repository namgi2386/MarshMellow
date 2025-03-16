package com.gbh.bank_test.bank.model.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "tbl_card_company")
public class CardCompany {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "card_company_pk")
    private int cardCompanyPk;

    @Column(name = "card_company_code")
    private String cardCompanyCode;

    @Column(name = "card_company_name")
    private String cardCompanyName;
}
