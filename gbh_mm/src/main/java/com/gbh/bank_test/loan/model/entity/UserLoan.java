package com.gbh.bank_test.loan.model.entity;

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

@Entity
@Table(name = "tbl_user_loan")
public class UserLoan {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "user_loan_pk")
    private long userLoanPk;

    @Column(name = "account_code")
    private String accountCode;

    // Enum 변경 해야할듯?
    @Column(name = "loan_status")
    private String loanStatus;

    @Column(name = "loan_period")
    private int loanPeriod;

    @Column(name = "loan_date")
    private Date loanDate;

    @Column(name = "maturity_date")
    private Date maturityDate;

    @Column(name = "loan_balance")
    private long loanBalance;

    @Column(name = "interest_rate")
    private double interestRate;

    @Column(name = "withdrawal_account_code")
    private String withdrawalAccountCode;

    @ManyToOne
    @JoinColumn(name = "user_pk")
    private User user;

    @ManyToOne
    @JoinColumn(name = "loan_pk")
    private Loan loan;
}
