package com.gbh.bank_test.loan.repo;

import com.gbh.bank_test.loan.model.entity.UserLoan;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserLoanRepository extends JpaRepository<UserLoan, Long> {

}
