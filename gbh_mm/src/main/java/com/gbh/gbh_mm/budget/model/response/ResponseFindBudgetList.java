package com.gbh.gbh_mm.budget.model.response;

import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class ResponseFindBudgetList {
    private int code;
    private String message;
    private List<BudgetData> data;

    @Data
    @Builder
    public static class BudgetData {
        private Long budgetPk;
        private Long budgetAmount;
        private String startDate;
        private String endDate;
        private String isSelected;
    }
}
