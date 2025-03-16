package com.gbh.bank_test.card.card.repo;

import com.gbh.bank_test.card.card.model.entity.UserCard;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserCardRepository extends JpaRepository<UserCard, Long> {

}
