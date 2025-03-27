package com.gbh.gbh_mm.household.model.vo.response;

import com.gbh.gbh_mm.household.model.entity.HouseholdCategory;
import com.gbh.gbh_mm.household.model.entity.HouseholdClassificationCategory;
import com.gbh.gbh_mm.household.model.entity.HouseholdDetailCategory;
import com.gbh.gbh_mm.household.model.enums.HouseholdClassificationEnum;
import com.gbh.gbh_mm.user.model.entity.User;
import jakarta.persistence.Column;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import lombok.Builder;
import lombok.Data;

@Data
public class ResponseUpdateHousehold {
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
