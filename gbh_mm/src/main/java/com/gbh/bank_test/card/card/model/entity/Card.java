package com.gbh.bank_test.card.card.model.entity;

import com.gbh.bank_test.bank.model.entity.CardCompany;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "tbl_card")
public class Card {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "card_pk")
    private int cardPk;

    @Column(name = "card_name")
    private String cardName;

    @Column(name = "baseline_performance")
    private long baselinePerformance;

    @Column(name = "max_benefit_limit")
    private long maxBenefitLimit;

    @Column(name = "card_description")
    private String cardDescription;

    @ManyToOne
    @JoinColumn(name = "card_type_pk")
    private CardType cardType;

    @ManyToOne
    @JoinColumn(name = "card_company_pk")
    private CardCompany cardCompany;
}
