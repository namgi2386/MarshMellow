package com.gbh.gbh_mm.household.repo;

import com.gbh.gbh_mm.household.model.entity.HouseholdClassificationCategory;
import org.springframework.data.jpa.repository.JpaRepository;

public interface HouseholdClassificationCategoryRepository extends
    JpaRepository<HouseholdClassificationCategory, Integer> {

}
