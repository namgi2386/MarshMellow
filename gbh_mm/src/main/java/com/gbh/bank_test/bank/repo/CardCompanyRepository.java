package com.gbh.bank_test.bank.repo;

import com.gbh.bank_test.bank.model.entity.CardCompany;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CardCompanyRepository extends JpaRepository<CardCompany, Integer> {

}
