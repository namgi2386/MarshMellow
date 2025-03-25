package com.gbh.gbh_mm.budget.service;

import com.gbh.gbh_mm.budget.model.entity.Budget;
import com.gbh.gbh_mm.budget.model.entity.BudgetCategory;
import com.gbh.gbh_mm.budget.model.response.ResponseCreateBudget;
import com.gbh.gbh_mm.budget.model.response.ResponseFindBudgetCategoryList;
import com.gbh.gbh_mm.budget.model.response.ResponseFindBudgetList;
import com.gbh.gbh_mm.budget.repo.BudgetCategoryRepository;
import com.gbh.gbh_mm.budget.repo.BudgetRepository;
import com.gbh.gbh_mm.common.exception.CustomException;
import com.gbh.gbh_mm.common.exception.ErrorCode;
import com.gbh.gbh_mm.user.model.entity.User;
import com.gbh.gbh_mm.user.repo.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class BudgetService {

    private final UserRepository userRepository;
    private final BudgetRepository budgetRepository;
    private final BudgetCategoryRepository budgetCategoryRepository;

    // 전체 예산 조회
    public ResponseFindBudgetList getBudgetList(Long userPk) {
        List<Budget> budgets = budgetRepository.findAllByUser_UserPk(userPk);

        if (budgets.isEmpty()) {
            throw new CustomException(ErrorCode.RESOURCE_NOT_FOUND);
        }
        List<ResponseFindBudgetList.BudgetData> budgetDataList = budgets.stream()
                .map(budget -> ResponseFindBudgetList.BudgetData.builder()
                        .budgetPk(budget.getBudgetPk())
                        .budgetAmount(budget.getBudgetAmount())
                        .startDate(budget.getStartDate())
                        .endDate(budget.getEndDate())
                        .isSelected(budget.getIsSelected())
                        .build()
                )
                .collect(Collectors.toList());

        return ResponseFindBudgetList.builder()
                .message("예산 리스트 조회")
                .budgetList(budgetDataList)
                .build();
    }

    // 예산 생성
    @Transactional
    public ResponseCreateBudget createBudget(Long userPk, Budget budget) {

        User user = userRepository.findById(userPk).
                orElseThrow(() -> new CustomException(ErrorCode.CHILD_NOT_FOUND));

        budget.setUser(user);
        budgetRepository.save(budget);

        return ResponseCreateBudget.builder()
                .message("예산 생성 완료")
                .budget(budget)
                .build();
    }

    // 세부 예산 생성
    @Transactional
    public BudgetCategory createBudgetCategory(Long budgetPk, BudgetCategory budgetCategory) {

        Budget budget = budgetRepository.findById(budgetPk)
                .orElseThrow(() -> new IllegalArgumentException("Budget Not Found"));

        budgetCategory.setBudget(budget);

        return budgetCategoryRepository.save(budgetCategory);
    }

    // 세부 예산 조회
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

    // 세부 예산 수정
    public BudgetCategory updateBudgetCategory(Long budgetCategoryPk, BudgetCategory budgetCategory) {
        BudgetCategory oldBudgetCategory = budgetCategoryRepository.findById(budgetCategoryPk)
                .orElseThrow(() -> new RuntimeException("Budget Category Not Found"));

        oldBudgetCategory.setBudgetCategoryName(budgetCategory.getBudgetCategoryName());
        oldBudgetCategory.setBudgetCategoryPrice(budgetCategory.getBudgetCategoryPrice());
        oldBudgetCategory.setBudgetExpendAmount(budgetCategory.getBudgetExpendAmount());
        return budgetCategoryRepository.save(oldBudgetCategory);


    }

}