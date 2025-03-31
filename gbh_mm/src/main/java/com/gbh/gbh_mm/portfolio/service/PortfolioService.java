package com.gbh.gbh_mm.portfolio.service;

import com.gbh.gbh_mm.portfolio.model.request.RequestCreateCategory;
import com.gbh.gbh_mm.portfolio.model.response.ResponseCreateCategory;

public interface PortfolioService {

    ResponseCreateCategory createCategory(RequestCreateCategory request);
}
