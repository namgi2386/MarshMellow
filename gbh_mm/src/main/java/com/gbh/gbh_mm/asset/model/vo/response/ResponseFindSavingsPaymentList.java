package com.gbh.gbh_mm.asset.model.vo.response;

import lombok.Data;

import java.util.List;
import java.util.Map;

@Data
public class ResponseFindSavingsPaymentList {
    private List<Map<String, Object>> paymentList;
}
