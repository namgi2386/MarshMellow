package com.gbh.bank_test.card.transaction.model.entity;

import com.gbh.bank_test.card.card.model.entity.Benefit;
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
@Table(name = "tbl_card_transaction")
public class CardTransaction {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "card_transaction_pk")
    private long cardTransactionPk;

    @Column(name = "merchant_name")
    private String merchantName;

    @Column(name = "transaction_date")
    private Date transactionDate;

    @Column(name = "transaction_time")
    private Timestamp transactionTime;

    @Column(name = "bill_statement_yn")
    private String billStatementYn;

    @ManyToOne
    @JoinColumn(name = "benefit_pk")
    private Benefit benefit;
}
