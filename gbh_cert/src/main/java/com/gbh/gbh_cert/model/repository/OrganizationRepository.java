package com.gbh.gbh_cert.model.repository;

import com.gbh.gbh_cert.model.entity.Organization;
import org.springframework.data.jpa.repository.JpaRepository;

public interface OrganizationRepository extends JpaRepository<Organization, String> {
}
