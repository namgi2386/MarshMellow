package com.gbh.gbh_mm.household.model.entity;

import com.gbh.gbh_mm.household.model.enums.HouseholdClassificationEnum;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;

@Entity
@Table(name = "tbl_household_classification_category")
@Data
public class HouseholdClassificationCategory {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "household_classification_category_pk")
    private int householdClassificationCategoryPk;

    @Column(name = "household_classification")
    @Enumerated(EnumType.STRING)
    private HouseholdClassificationEnum householdClassificationEnum;
}
