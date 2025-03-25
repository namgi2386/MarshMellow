package com.gbh.gbh_mm.household.service;

import com.gbh.gbh_mm.household.repo.HouseholdCategoryRepository;
import com.gbh.gbh_mm.household.repo.HouseholdClassificationCategoryRepository;
import com.gbh.gbh_mm.household.repo.HouseholdDetailCategoryRepository;
import com.gbh.gbh_mm.household.repo.AiCategoryRepository;
import com.gbh.gbh_mm.household.repo.HouseholdRepository;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@AllArgsConstructor
public class HouseholdServiceImpl implements HouseholdService {
    private final HouseholdRepository householdRepository;
    private final HouseholdCategoryRepository householdCategoryRepository;
    private final HouseholdDetailCategoryRepository householdDetailCategoryRepository;
    private final HouseholdClassificationCategoryRepository householdClassificationCategoryRepository;
    private final AiCategoryRepository aiCategoryRepository;
}
