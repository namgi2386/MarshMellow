package com.gbh.bank_test.loan.repo;

import com.gbh.bank_test.loan.model.entity.LoanRepayment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface LoanRepaymentRepository extends JpaRepository<LoanRepayment, Long> {
}
