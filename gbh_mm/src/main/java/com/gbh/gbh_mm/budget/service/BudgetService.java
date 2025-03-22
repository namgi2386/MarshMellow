package com.gbh.gbh_mm.budget.service;

import com.gbh.gbh_mm.budget.model.entity.Budget;
import com.gbh.gbh_mm.budget.model.response.ResponseFindBudgetList;
import com.gbh.gbh_mm.budget.repo.BudgetRepository;
import com.gbh.gbh_mm.user.model.entity.User;
import com.gbh.gbh_mm.user.repo.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class BudgetService {

    @Autowired
    private BudgetRepository budgetRepository;
    @Autowired
    private UserRepository userRepository;

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

    @Transactional
    public Budget createBudget(Long userPk, Budget budget) {

        User user = userRepository.findById(userPk)
                .orElseThrow(() -> new IllegalArgumentException("User Not Found"));

        budget.setUser(user);

        return budgetRepository.save(budget);
    }
}
