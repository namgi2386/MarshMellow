package com.gbh.gbh_mm.portfolio.service;

import com.gbh.gbh_mm.portfolio.model.request.RequestCreateCategory;
import com.gbh.gbh_mm.portfolio.model.request.RequestDeleteCategory;
import com.gbh.gbh_mm.portfolio.model.request.RequestFindCategoryList;
import com.gbh.gbh_mm.portfolio.model.request.RequestUpdateCategory;
import com.gbh.gbh_mm.portfolio.model.response.ResponseCreateCategory;
import com.gbh.gbh_mm.portfolio.model.response.ResponseDeleteCategory;
import com.gbh.gbh_mm.portfolio.model.response.ResponseFindCategoryList;
import com.gbh.gbh_mm.portfolio.model.response.ResponseUpdateCategory;

public interface PortfolioService {

    ResponseCreateCategory createCategory(RequestCreateCategory request);

    ResponseFindCategoryList findCategoryList(RequestFindCategoryList request);

    ResponseDeleteCategory deleteCategory(RequestDeleteCategory request);

    ResponseUpdateCategory updateCategory(RequestUpdateCategory request);
}
