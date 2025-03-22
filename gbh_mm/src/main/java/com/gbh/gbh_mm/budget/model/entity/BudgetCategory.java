package com.gbh.gbh_mm.budget.model.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Getter
@Setter
@Table(name = "category")
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BudgetCategory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long budgetCategoryPk;

    private String budgetCategoryName;

    private Long budgetCategoryPrice;

    private Long budgetExpendAmount;

    @ManyToOne
    @JoinColumn(name = "budget_pk")
    private Budget budget;


}
