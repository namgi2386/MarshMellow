package com.gbh.bank_test.card.transaction.repo;

import com.gbh.bank_test.card.transaction.model.entity.CardTransaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface CardTransactionRepository extends JpaRepository<CardTransaction, Long> {

}
