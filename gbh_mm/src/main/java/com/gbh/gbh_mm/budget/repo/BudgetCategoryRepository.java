package com.gbh.gbh_mm.budget.repo;

import com.gbh.gbh_mm.budget.model.entity.Budget;
import com.gbh.gbh_mm.budget.model.entity.BudgetCategory;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface BudgetCategoryRepository extends JpaRepository<BudgetCategory, Long> {
    List<BudgetCategory> findAllByBudget_BudgetPk(Long budgetPk);
}
