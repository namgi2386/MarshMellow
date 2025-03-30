package com.gbh.gbh_mm.household.model.vo.request;

import lombok.Getter;

@Getter
public class RequestSearchHousehold {
    private String startDate;
    private String endDate;
    private long userPk;
    private String keyword;
}
