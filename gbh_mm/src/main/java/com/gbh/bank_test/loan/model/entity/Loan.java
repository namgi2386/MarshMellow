package com.gbh.bank_test.loan.model.entity;

import com.gbh.bank_test.bank.model.entity.Bank;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "tbl_loan")
public class Loan {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "loan_pk")
    private int loanPk;

    @Column(name = "account_type_unique_no")
    private String accountTypeUniqueNo;

    @Column(name = "rating_unique_no")
    private String ratingUniqueNo;

    @Column(name = "rating_name")
    private String ratingName;

    @Column(name = "loan_name")
    private String loanName;

    @Column(name = "loan_period")
    private int loanPeriod;

    @Column(name = "min_loan_balance")
    private long minLoanBalance;

    @Column(name = "max_loan_balance")
    private long maxLoanBalance;

    @Column(name = "interest_rate")
    private double interestRate;

    @Column(name = "account_description")
    public String accountDescription;

    @Column(name = "loan_type_code")
    private String loanTypeCode;

    @Column(name = "loan_type_name")
    private String loanTypeName;

    @Column(name = "repayment_method_type_code")
    private String repaymentMethodTypeCode;

    @Column(name = "repayment_method_type_name")
    private String repaymentMethodTypeName;

    @ManyToOne
    @JoinColumn(name = "bank_pk")
    private Bank bank;
}
