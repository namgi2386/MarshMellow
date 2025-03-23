package com.gbh.gbh_mm.asset.model.dto;

import com.gbh.gbh_mm.asset.model.entity.Deposit;
import java.util.List;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class DepositListDto {
    private long totalAmount;
    private List<Deposit> depositList;
}
