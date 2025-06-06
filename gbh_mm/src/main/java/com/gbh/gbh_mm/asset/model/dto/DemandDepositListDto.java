package com.gbh.gbh_mm.asset.model.dto;

import com.gbh.gbh_mm.asset.model.entity.DemandDeposit;
import java.util.List;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class DemandDepositListDto {
    private String totalAmount;
    private List<DemandDeposit> demandDepositList;
}
