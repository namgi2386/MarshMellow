package com.gbh.bank_test.loan.model.entity;

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
@Table(name = "tbl_loan_repayment")
public class LoanRepayment {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "loan_repayment_pk")
    private long loanRepaymentPk;

    @Column(name = "remaining_loan_balance")
    private double remainingLoanBalance;

    @Column(name = "installment_number")
    private int installmentNumber;

    @Column(name = "payment_balance")
    private long paymentBalance;

    @Column(name = "repayment_attempt_date")
    private Date repaymentAttemptDate;

    @Column(name = "repayment_attempt_time")
    private Timestamp repaymentAttemptTime;

    @Column(name = "repayment_actual_date")
    private Date repaymentActualDate;

    @Column(name = "repayment_actual_time")
    private Timestamp repaymentActualTime;

    @Column(name = "failure_reason")
    private String failureReason;

    @ManyToOne
    @JoinColumn(name = "user_loan_pk")
    private UserLoan userLoan;

}
