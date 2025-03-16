package com.gbh.bank_test.card.card.model.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "tbl_card_benefit")
public class CardBenefit {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "card_benefit_id")
    private int cardBenefitPk;

    @ManyToOne
    @JoinColumn(name = "card_pk")
    private Card card;

    @ManyToOne
    @JoinColumn(name = "benefit_pk")
    private Benefit benefit;
}
