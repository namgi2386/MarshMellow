package com.gbh.gbh_mm.budget.service;

import com.gbh.gbh_mm.budget.model.entity.Budget;
import com.gbh.gbh_mm.budget.model.entity.BudgetCategory;
import com.gbh.gbh_mm.budget.model.request.RequestUpdateBudgetCategory;
import com.gbh.gbh_mm.budget.model.response.*;
import com.gbh.gbh_mm.budget.repo.BudgetCategoryRepository;
import com.gbh.gbh_mm.budget.repo.BudgetRepository;
import com.gbh.gbh_mm.common.exception.CustomException;
import com.gbh.gbh_mm.common.exception.ErrorCode;
import com.gbh.gbh_mm.user.model.entity.User;
import com.gbh.gbh_mm.user.repo.UserRepository;
import lombok.RequiredArgsConstructor;
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
                .budgetPk(budget.getBudgetPk())
                .budgetAmount(budget.getBudgetAmount())
                .startDate(budget.getStartDate())
                .endDate(budget.getEndDate())
                .isSelected(budget.getIsSelected())
                .build();
    }

    // 세부 예산 생성
    @Transactional
    public ResponseCreateBudgetCategory createBudgetCategory(Long budgetPk, BudgetCategory budgetCategory) {

        Budget budget = budgetRepository.findById(budgetPk)
                .orElseThrow(() -> new CustomException(ErrorCode.RESOURCE_NOT_FOUND));

        budgetCategory.setBudget(budget);
        budgetCategoryRepository.save(budgetCategory);

        return ResponseCreateBudgetCategory.builder()
                .message("세부 예산 생성 완료")
                .budgetCategoryPk(budgetCategory.getBudgetCategoryPk())
                .budgetCategoryName(budgetCategory.getBudgetCategoryName())
                .budgetCategoryPrice(budgetCategory.getBudgetCategoryPrice())
                .relatedBudgetPk(budgetPk)
                .build();
    }

    // 세부 예산 조회
    public ResponseFindBudgetCategoryList getBudgetCategoryList(Long budgetPk) {

        budgetRepository.findById(budgetPk)
                .orElseThrow(() -> new CustomException(ErrorCode.RESOURCE_NOT_FOUND));

        List<ResponseFindBudgetCategoryList.BudgetCategoryData> categoryDataList =
                budgetCategoryRepository.findAllByBudget_BudgetPk(budgetPk)
                        .stream()
                        .map(budgetCategory -> ResponseFindBudgetCategoryList.BudgetCategoryData.builder()
                                .budgetCategoryPk(budgetCategory.getBudgetCategoryPk())
                                .budgetCategoryName(budgetCategory.getBudgetCategoryName())
                                .budgetCategoryPrice(budgetCategory.getBudgetCategoryPrice())
                                .budgetExpendAmount(budgetCategory.getBudgetExpendAmount())
                                .build()
                        )
                        .collect(Collectors.toList()); // 변환 결과 저장

        if (categoryDataList.isEmpty()) {
            throw new CustomException(ErrorCode.RESOURCE_NOT_FOUND);
        }
        return ResponseFindBudgetCategoryList.builder()
                .message("세부 예산 조회")
                .budgetCategoryList(categoryDataList)
                .build();

    }

    // 세부 예산 수정
    public ResponseUpdateBudgetCategory updateBudgetCategory(Long budgetCategoryPk, RequestUpdateBudgetCategory requestUpdateBudgetCategory) {
        BudgetCategory oldBudgetCategory = budgetCategoryRepository.findById(budgetCategoryPk)
                .orElseThrow(() -> new CustomException(ErrorCode.RESOURCE_NOT_FOUND));

        Long oldBudgetCategoryPrice = oldBudgetCategory.getBudgetCategoryPrice();
        Long newBudgetCategoryPrice = requestUpdateBudgetCategory.getBudgetCategoryPrice();

        oldBudgetCategory.setBudgetCategoryPrice(newBudgetCategoryPrice);
        budgetCategoryRepository.save(oldBudgetCategory);

        return ResponseUpdateBudgetCategory.builder()
                .message("세부 예산 수정 완료")
                .budgetCategoryPk(budgetCategoryPk)
                .oldBudgetCategoryPrice(oldBudgetCategoryPrice)
                .newBudgetCategoryPrice(newBudgetCategoryPrice)
                .build();


    }

}