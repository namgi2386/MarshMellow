package com.gbh.bank_test.card.card.model.entity;

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
@Table(name = "tbl_user_card")
public class UserCard {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "user_card_pk")
    private int userCardPk;

    @Column(name = "cvc")
    private String cvc;

    @Column(name = "withdrawal_account_code")
    private String withdrawalAccountCode;

    @Column(name = "withdrawal_date")
    private int withdrawalDate;

    @Column(name = "expiry_date")
    private Date expiryDate;

    @ManyToOne
    @JoinColumn(name = "user_pk")
    private User user;

    @ManyToOne
    @JoinColumn(name = "card_pk")
    private Card card;
}
