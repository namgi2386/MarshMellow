package com.gbh.gbh_mm.budget.controller;

import com.gbh.gbh_mm.budget.model.entity.Budget;
import com.gbh.gbh_mm.budget.model.entity.BudgetCategory;
import com.gbh.gbh_mm.budget.model.response.ResponseCreateBudget;
import com.gbh.gbh_mm.budget.model.response.ResponseCreateBudgetCategory;
import com.gbh.gbh_mm.budget.model.response.ResponseFindBudgetCategoryList;
import com.gbh.gbh_mm.budget.model.response.ResponseFindBudgetList;
import com.gbh.gbh_mm.budget.service.BudgetService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("api/mm/budget")
public class BudgetController {

    @Autowired
    private BudgetService budgetService;

    // 예산 리스트 조회
    @GetMapping("/{userPk}")
    public ResponseEntity<ResponseFindBudgetList> getBudgetList(@PathVariable Long userPk) {
        List<ResponseFindBudgetList.BudgetData> budgetData = budgetService.getBudgetList(userPk);

        ResponseFindBudgetList response = ResponseFindBudgetList.builder()
                .code(200)
                .message("예산 리스트 조회")
                .data(budgetData)
                .build();
        return ResponseEntity.ok(response);
    }

    // 예산 생성
    @PostMapping("/{userPk}")
    public ResponseEntity<ResponseCreateBudget> createBudget(@PathVariable Long userPk, @RequestBody Budget budget) {

        budgetService.createBudget(userPk, budget);

        ResponseCreateBudget response = ResponseCreateBudget.builder()
                .code(200)
                .message("예산 생성 완료")
                .build();

        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    // 세부 예산 생성
    @PostMapping("/detail/{budgetPk}")
    public ResponseEntity<ResponseCreateBudgetCategory> createBudgetCategory(@PathVariable Long budgetPk, @RequestBody BudgetCategory budgetCategory) {
        budgetService.createBudgetCategory(budgetPk, budgetCategory);

        ResponseCreateBudgetCategory response = ResponseCreateBudgetCategory.builder()
                .code(200)
                .message("세부 예산 생성")
                .data(budgetCategory)
                .build();
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    // 세부 예산 리스트 조회
    @GetMapping("detail/{budgetPk}")
    public ResponseEntity<ResponseFindBudgetCategoryList> getBudgetCategoryList(@PathVariable Long budgetPk) {
        List<ResponseFindBudgetCategoryList.BudgetCategoryData> budgetCategoryData = budgetService.getBudgetCategoryList(budgetPk);

        ResponseFindBudgetCategoryList response = ResponseFindBudgetCategoryList.builder()
                .code(200)
                .message("세부 예산 리스트 조회")
                .data(budgetCategoryData)
                .build();
        return ResponseEntity.ok(response);
    }
}
