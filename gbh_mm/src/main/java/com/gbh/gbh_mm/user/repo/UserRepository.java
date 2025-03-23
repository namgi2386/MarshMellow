package com.gbh.gbh_mm.user.repo;

import com.gbh.gbh_mm.user.model.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    User findByUserKey(String userKey);
}
