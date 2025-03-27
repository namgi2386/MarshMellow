package com.gbh.gbh_mm.household.model.vo.response;

import com.gbh.gbh_mm.household.model.entity.Household;
import com.gbh.gbh_mm.household.model.entity.HouseholdCategory;
import com.gbh.gbh_mm.household.model.entity.HouseholdClassificationCategory;
import com.gbh.gbh_mm.household.model.entity.HouseholdDetailCategory;
import com.gbh.gbh_mm.household.model.enums.HouseholdClassificationEnum;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.checkerframework.checker.units.qual.A;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ResponseCreateHousehold {
    private long householdPk;
    private String tradeName;
    private String tradeDate;
    private String tradeTime;
    private int householdAmount;
    private String householdMemo;
    private String paymentMethod;
    private String paymentCancelYn;
    private String exceptedBudgetYn;
    private String householdCategory;
    private String householdDetailCategory;
    private HouseholdClassificationEnum householdClassificationCategory;
}
