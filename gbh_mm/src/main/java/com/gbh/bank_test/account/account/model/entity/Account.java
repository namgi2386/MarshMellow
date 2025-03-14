package com.gbh.bank_test.account.account.model.entity;

import com.gbh.bank_test.bank.model.entity.Bank;
import com.gbh.bank_test.user.model.entity.User;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.util.Date;
import lombok.Data;

@Data
@Entity
@Table(name = "tbl_account")
public class Account {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "account_pk")
    private int accountPk;

    @Column(name = "account_code")
    private String accountCode;

    @Column(name = "account_create_date")
    private Date accountCreateDate;

    @Column(name = "account_expiry_date")
    private Date accountExpiryDate;

    @Column(name = "daily_transfer_limit")
    private long dailyTransferLimit;

    @Column(name = "one_time_transfer_limit")
    private long oneTimeTransferLimit;

    @Column(name = "account_balance")
    private long accountBalance;

    @Column(name = "last_transaction_date")
    private Date lastTransactionDate;

    @Column(name = "withdrawal_account_code")
    private String withdrawalAccountCode;

    @Column(name = "deposit_balance")
    private long depositBalance;

    @Column(name = "subscription_period")
    private int subscriptionPeriod;

    @Column(name = "interest_rate")
    private double interestRate;

    @Column(name = "installment_number")
    private int installmentNumber;

    @Column(name = "total_balance")
    private int totalBalance;

    @ManyToOne
    @JoinColumn(name = "user_pk")
    private User user;

    @ManyToOne
    @JoinColumn(name = "product_pk")
    private Product product;

    @ManyToOne
    @JoinColumn(name = "bank_pk")
    private Bank bank;

    @ManyToOne
    @JoinColumn(name = "withdrawal_bank_pk")
    private Bank withdrawalBank;
}
