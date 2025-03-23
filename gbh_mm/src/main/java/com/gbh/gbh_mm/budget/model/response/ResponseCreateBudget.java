package com.gbh.gbh_mm.budget.model.response;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class ResponseCreateBudget {
    private int code;
    private String message;


}
