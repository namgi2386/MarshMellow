package com.gbh.gbh_cert.model.repository;

import com.gbh.gbh_cert.model.entity.Certificate;
import com.gbh.gbh_cert.model.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface CertficateRepository extends JpaRepository<Certificate, Long> {
    Optional<Certificate> findByUser(User user);

    Optional<Certificate> findByUserAndCertStatus(User user, Certificate.CertStatus certStatus);
}
