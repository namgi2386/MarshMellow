package com.gbh.gbh_mm.budget.controller;

import com.gbh.gbh_mm.budget.model.entity.Budget;
import com.gbh.gbh_mm.budget.model.entity.BudgetCategory;
import com.gbh.gbh_mm.budget.model.response.*;
import com.gbh.gbh_mm.budget.service.BudgetService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("api/mm/budget")
@RequiredArgsConstructor
public class BudgetController {

    private final BudgetService budgetService;

    // 예산 리스트 조회
    @GetMapping("/{userPk}")
    public ResponseFindBudgetList getBudgetList(@PathVariable Long userPk) {
        return budgetService.getBudgetList(userPk);
    }

    // 예산 생성
    @PostMapping("/{userPk}")
    public ResponseCreateBudget createBudget(@PathVariable Long userPk, @RequestBody Budget budget) {
        return budgetService.createBudget(userPk, budget);
    }

    // 세부 예산 리스트 조회
    @GetMapping("/detail/{budgetPk}")
    public ResponseEntity<ResponseFindBudgetCategoryList> getBudgetCategoryList(@PathVariable Long budgetPk) {
        List<ResponseFindBudgetCategoryList.BudgetCategoryData> budgetCategoryData = budgetService.getBudgetCategoryList(budgetPk);

        ResponseFindBudgetCategoryList response = ResponseFindBudgetCategoryList.builder()
                .code(200)
                .message("세부 예산 리스트 조회")
                .data(budgetCategoryData)
                .build();
        return ResponseEntity.ok(response);
    }

    // 세부 예산 생성
    @PostMapping("/detail/{budgetPk}")
    public ResponseEntity<ResponseCreateBudgetCategory> createBudgetCategory(@PathVariable Long budgetPk, @RequestBody BudgetCategory budgetCategory) {
        budgetService.createBudgetCategory(budgetPk, budgetCategory);

        ResponseCreateBudgetCategory response = ResponseCreateBudgetCategory.builder()
                .code(200)
                .message("세부 예산 생성 완료")
                .build();
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    // 세부 예산 수정
    @PutMapping("/detail/{budgetCategoryPk}")
    public ResponseEntity<ResponseUpdateBudgetCategory> updateBudgetCategory(@PathVariable Long budgetCategoryPk, @RequestBody BudgetCategory budgetCategory) {

        try {
            BudgetCategory updateBudgetCategory = budgetService.updateBudgetCategory(budgetCategoryPk, budgetCategory);
            return new ResponseEntity<>(ResponseUpdateBudgetCategory.builder()
                    .code(200)
                    .message("예산 카테고리 수정 완료")
                    .build(), HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(ResponseUpdateBudgetCategory.builder()
                    .code(500)
                    .message("예산 카테고리 수정 실패: " + e.getMessage())
                    .build(), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}
