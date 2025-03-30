package com.gbh.gbh_cert.model.repository;

import com.gbh.gbh_cert.model.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByConnectionInformation(String connectionInformation);

    Optional<User> findByEmail(String email);

    boolean existsByEmail(String email);
}
