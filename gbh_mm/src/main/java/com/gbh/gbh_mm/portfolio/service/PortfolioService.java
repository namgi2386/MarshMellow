package com.gbh.gbh_mm.portfolio.service;

import com.gbh.gbh_mm.portfolio.model.request.RequestCreateCategory;
import com.gbh.gbh_mm.portfolio.model.request.RequestDeleteCategory;
import com.gbh.gbh_mm.portfolio.model.request.RequestFindCategoryList;
import com.gbh.gbh_mm.portfolio.model.request.RequestFindPortfolioList;
import com.gbh.gbh_mm.portfolio.model.request.RequestUpdateCategory;
import com.gbh.gbh_mm.portfolio.model.response.ResponseCreateCategory;
import com.gbh.gbh_mm.portfolio.model.response.ResponseCreatePortfolio;
import com.gbh.gbh_mm.portfolio.model.response.ResponseDeleteCategory;
import com.gbh.gbh_mm.portfolio.model.response.ResponseFindCategoryList;
import com.gbh.gbh_mm.portfolio.model.response.ResponseFindPortfolioList;
import com.gbh.gbh_mm.portfolio.model.response.ResponseUpdateCategory;
import org.springframework.web.multipart.MultipartFile;

public interface PortfolioService {

    ResponseCreateCategory createCategory(RequestCreateCategory request);

    ResponseFindCategoryList findCategoryList(RequestFindCategoryList request);

    ResponseDeleteCategory deleteCategory(RequestDeleteCategory request);

    ResponseUpdateCategory updateCategory(RequestUpdateCategory request);

    ResponseCreatePortfolio createPortfolio
        (MultipartFile file, String portfolioMemo, String fileName, long userPk, int portfolioCategoryPk);

    ResponseFindPortfolioList findPortfolioList(RequestFindPortfolioList request);
}
