package com.gbh.gbh_mm.budget.service;

import com.gbh.gbh_mm.budget.model.entity.Budget;
import com.gbh.gbh_mm.budget.model.response.ResponseFindBudgetList;
import com.gbh.gbh_mm.budget.repo.BudgetRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class BudgetService {

    @Autowired
    private BudgetRepository budgetRepository;

    public List<ResponseFindBudgetList.BudgetData> getBudgetList(Long userPk) {
        List<Budget> budgets = budgetRepository.findAllByUser_UserPk(userPk);
        List<ResponseFindBudgetList.BudgetData> budgetDataList = budgets.stream()
                .map(budget -> ResponseFindBudgetList.BudgetData.builder().
                        budgetPk(budget.getBudgetPk())
                        .budgetAmount(budget.getBudgetAmount())
                        .startDate(budget.getStartDate())
                        .endDate(budget.getEndDate())
                        .isSelected(budget.getIsSelected())
                        .build()
                )
                .collect(Collectors.toList());

        return budgetDataList;
    }
}
