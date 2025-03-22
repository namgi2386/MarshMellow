package com.gbh.gbh_mm.budget.controller;

import com.gbh.gbh_mm.budget.model.response.ResponseFindBudgetList;
import com.gbh.gbh_mm.budget.service.BudgetService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("api/mm/budget")
public class BudgetController {

    @Autowired
    private BudgetService budgetService;

    @GetMapping("/{userPk}")
    public ResponseEntity<ResponseFindBudgetList> getBudgetList(@PathVariable Long userPk) {
        List<ResponseFindBudgetList.BudgetData> budgetData = budgetService.getBudgetList(userPk);

        ResponseFindBudgetList response = ResponseFindBudgetList.builder()
                .code(200)
                .message("예산 리스트 조회")
                .data(budgetData)
                .build();
        System.out.println("hi");
        return ResponseEntity.ok(response);
    }
}
