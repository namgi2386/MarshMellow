package com.gbh.gbh_mm.budget.service;

import com.gbh.gbh_mm.budget.model.entity.Budget;
import com.gbh.gbh_mm.budget.model.entity.BudgetCategory;
import com.gbh.gbh_mm.budget.model.response.ResponseFindBudgetCategoryList;
import com.gbh.gbh_mm.budget.model.response.ResponseFindBudgetList;
import com.gbh.gbh_mm.budget.repo.BudgetCategoryRepository;
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
    private UserRepository userRepository;
    @Autowired
    private BudgetRepository budgetRepository;
    @Autowired
    private BudgetCategoryRepository budgetCategoryRepository;

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

    @Transactional
    public BudgetCategory createBudgetCategory(Long budgetPk, BudgetCategory budgetCategory) {

        Budget budget = budgetRepository.findById(budgetPk)
                .orElseThrow(() -> new IllegalArgumentException("Budget Not Found"));

        budgetCategory.setBudget(budget);

        return budgetCategoryRepository.save(budgetCategory);
    }

    public List<ResponseFindBudgetCategoryList.BudgetCategoryData> getBudgetCategoryList(Long budgetPk) {
        List<BudgetCategory> budgetCategories = budgetCategoryRepository.findAllByBudget_BudgetPk(budgetPk);
        List<ResponseFindBudgetCategoryList.BudgetCategoryData> budgetCategoryDataList = budgetCategories.stream()
                .map(budgetCategory -> ResponseFindBudgetCategoryList.BudgetCategoryData.builder()
                        .budgetCategoryPk(budgetCategory.getBudgetCategoryPk())
                        .budgetCategoryName(budgetCategory.getBudgetCategoryName())
                        .budgetCategoryPrice(budgetCategory.getBudgetCategoryPrice())
                        .budgetExpendAmount(budgetCategory.getBudgetExpendAmount())
                        .build()
                )
                .collect(Collectors.toList());

        return budgetCategoryDataList;

    }
}