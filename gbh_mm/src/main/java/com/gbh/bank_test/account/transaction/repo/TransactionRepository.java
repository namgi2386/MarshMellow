package com.gbh.bank_test.account.transaction.repo;

import com.gbh.bank_test.account.transaction.model.entity.Transaction;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface TransactionRepository extends JpaRepository<Transaction, Long> {

}
