package com.gbh.bank_test.bank.repo;

import com.gbh.bank_test.bank.model.entity.Bank;
import org.springframework.data.jpa.repository.JpaRepository;

public interface BankRepository extends JpaRepository<Bank, Integer> {

}
