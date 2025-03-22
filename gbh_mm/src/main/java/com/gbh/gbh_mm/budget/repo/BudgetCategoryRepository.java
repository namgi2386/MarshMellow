package com.gbh.gbh_mm.budget.repo;

import com.gbh.gbh_mm.budget.model.entity.BudgetCategory;
import org.springframework.data.jpa.repository.JpaRepository;

public interface BudgetCategoryRepository extends JpaRepository<BudgetCategory, Long> {
}
