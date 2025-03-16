package com.gbh.bank_test.card.card.model.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "tbl_benefit")
public class Benefit {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "benefit_pk")
    private int benefitPk;

    @Column(name = "benefit")
    private String benefit;

    @Column(name = "discount_rate")
    private double discountRate;

    @Column(name = "benefit_code")
    private String benefitCode;
}
