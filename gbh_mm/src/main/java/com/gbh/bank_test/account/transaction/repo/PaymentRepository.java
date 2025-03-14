package com.gbh.bank_test.account.transaction.repo;

import com.gbh.bank_test.account.transaction.model.entity.Payment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface PaymentRepository extends JpaRepository<Payment, Long> {

}
