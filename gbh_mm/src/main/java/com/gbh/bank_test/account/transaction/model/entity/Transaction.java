package com.gbh.bank_test.account.transaction.model.entity;

import com.gbh.bank_test.account.account.model.entity.Account;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.sql.Timestamp;
import java.util.Date;

@Entity
@Table(name = "tbl_trasaction")
public class Transaction {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "transaction_pk")
    private long transactionPk;

    @Column(name = "transaction_date")
    private Date transactionDate;

    @Column(name = "transaction_time")
    private Timestamp transactionTime;

    @Column(name = "transaction_balance")
    private long transactionBalance;

    @Column(name = "transaction_after_balance")
    private long transactionAfterBalance;

    @Column(name = "transaction_summary")
    private String transactionSummary;

    @Column(name = "transaction_memo")
    private String transactionMemo;

    @ManyToOne
    @JoinColumn(name = "account_pk")
    private Account account;

    @ManyToOne
    @JoinColumn(name = "transaction_category_pk")
    private TransactionCategory transactionCategory;
}
