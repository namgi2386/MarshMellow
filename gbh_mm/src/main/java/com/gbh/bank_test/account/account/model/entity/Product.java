package com.gbh.bank_test.account.account.model.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "tbl_product")
public class Product {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "product_pk")
    private int productPk;

    @Column(name = "product_name")
    private String productName;

    @Column(name = "product_description")
    private String productDescription;

    @Column(name = "subscription_period")
    private int subscriptionPeriod;

    @Column(name = "min_subscription_balance")
    private long minSubscriptionBalance;

    @Column(name = "max_subscription_balance")
    private long maxSubscriptionBalance;

    @Column(name = "interest_rate")
    private double interestRate;

    @Column(name = "rate_description")
    private String rateDescription;
}
