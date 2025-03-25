package com.gbh.gbh_mm.household.repo;

import com.gbh.gbh_mm.household.model.entity.HouseholdClassificationCategory;
import com.gbh.gbh_mm.household.model.enums.HouseholdClassificationEnum;
import org.springframework.data.jpa.repository.JpaRepository;

public interface HouseholdClassificationCategoryRepository extends
    JpaRepository<HouseholdClassificationCategory, Integer> {

    HouseholdClassificationCategory findByHouseholdClassificationEnum
        (HouseholdClassificationEnum householdClassification);
}
