package com.gbh.gbh_mm.asset.model.vo.response;

import lombok.Data;

import java.util.List;
import java.util.Map;

@Data
public class ResponseFindCardTransactionList {
    private long estimatedBalance;
    private List<Map<String, Object>> transactionList;
}
