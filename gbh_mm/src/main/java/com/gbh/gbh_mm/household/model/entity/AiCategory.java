package com.gbh.gbh_mm.household.model.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "tbl_ai_category")
public class AiCategory {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "ai_category_pk")
    private int aiCategoryPk;

    @Column(name = "ai_category")
    private String aiCategory;
}
