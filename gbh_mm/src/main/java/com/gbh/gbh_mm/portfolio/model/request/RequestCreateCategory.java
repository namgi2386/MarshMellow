package com.gbh.gbh_mm.portfolio.model.request;

import lombok.Getter;

@Getter
public class RequestCreateCategory {
    private long userPk;
    private String categoryName;
    private String categoryMemo;
}
