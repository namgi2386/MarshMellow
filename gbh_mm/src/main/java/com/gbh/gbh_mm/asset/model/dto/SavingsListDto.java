package com.gbh.gbh_mm.asset.model.dto;

import com.gbh.gbh_mm.asset.model.entity.Savings;
import java.util.List;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class SavingsListDto {
    private long totalAmount;
    private List<Savings> savingsList;
}
