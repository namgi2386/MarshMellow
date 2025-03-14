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
@Table(name = "tbl_payment")
public class Payment {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "payment_pk")
    private long paymentPk;

    @Column(name = "payment_date")
    private Date paymentDate;

    @Column(name = "payment_time")
    private Timestamp paymentTime;

    @Column(name = "payment_balance")
    private long paymentBalance;

    @Column(name = "payment_status")
    private String paymentStatus;

    @Column(name = "failure_reason")
    private String failureReason;

    @Column(name = "deposit_installment")
    private int depositInstallment;

    @ManyToOne
    @JoinColumn(name = "account_pk")
    private Account account;
}
