package com.gbh.gbh_mm.asset.model.vo.response;

import lombok.Builder;
import lombok.Data;

import java.util.List;
import java.util.Map;

@Data
public class ResponseFindDepositDemandTransactionList {
    List<Map<String, Object>> transactionList;
}
