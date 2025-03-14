package com.gbh.bank_test.card.card.repo;

import com.gbh.bank_test.card.card.model.entity.Card;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CardRepository extends JpaRepository<Card, Integer> {

}
