package com.gbh.gbh_mm.household.model.vo.response;

import com.gbh.gbh_mm.household.model.enums.HouseholdClassificationEnum;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class ResponseFindHousehold {
    private long householdId;
    private String tradeName;
    private String tradeDate;
    private String tradeTime;
    private int householdAmount;
    private String householdMemo;
    private String paymentCancelYn;
    private String exceptedBudgetYn;
    private String householdCategory;
    private String householdDetailCategory;
    private HouseholdClassificationEnum householdClassification;
}
