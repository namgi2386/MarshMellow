package com.gbh.gbh_mm.asset.repo;

import com.gbh.gbh_mm.asset.model.entity.WithdrawalAccount;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface WithdrawalAccountRepository extends JpaRepository<WithdrawalAccount, Integer> {
}
