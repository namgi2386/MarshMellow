package com.gbh.gbh_mm.asset.model.vo.response;

import lombok.Data;

import java.util.List;
import java.util.Map;

@Data
public class ResponseFindLoanPaymentList {
    private String status;
    private long loanBalance;
    private long remainingLoanBalance;
    private List<Map<String, Object>> repaymentRecords;
}
