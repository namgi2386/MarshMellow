package com.gbh.gbh_mm.portfolio.controller;

import com.gbh.gbh_mm.portfolio.model.entity.Portfolio;
import com.gbh.gbh_mm.portfolio.model.request.RequestCreateCategory;
import com.gbh.gbh_mm.portfolio.model.request.RequestDeleteCategory;
import com.gbh.gbh_mm.portfolio.model.request.RequestFindCategoryList;
import com.gbh.gbh_mm.portfolio.model.request.RequestUpdateCategory;
import com.gbh.gbh_mm.portfolio.model.response.ResponseCreateCategory;
import com.gbh.gbh_mm.portfolio.model.response.ResponseCreatePortfolio;
import com.gbh.gbh_mm.portfolio.model.response.ResponseDeleteCategory;
import com.gbh.gbh_mm.portfolio.model.response.ResponseFindCategoryList;
import com.gbh.gbh_mm.portfolio.model.response.ResponseUpdateCategory;
import com.gbh.gbh_mm.portfolio.service.PortfolioService;
import lombok.AllArgsConstructor;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/portfolio")
@AllArgsConstructor
public class PortfolioController {
    private final PortfolioService portfolioService;

    @PostMapping("/category")
    public ResponseCreateCategory createPortfolioCategory(
        @RequestBody RequestCreateCategory request
    ) {
        ResponseCreateCategory response = portfolioService.createCategory(request);

        return response;
    }

    @GetMapping("/category-list")
    public ResponseFindCategoryList findPortfolioCategoryList(
        @RequestBody RequestFindCategoryList request
    ) {
        return portfolioService.findCategoryList(request);
    }

    @DeleteMapping("/category")
    public ResponseDeleteCategory deletePortfolioCategory(
        @RequestBody RequestDeleteCategory request
    ) {
        return portfolioService.deleteCategory(request);
    }

    @PatchMapping("/category")
    public ResponseUpdateCategory updatePortfolioCategory(
        @RequestBody RequestUpdateCategory request
    ) {
        return portfolioService.updateCategory(request);
    }

    @PostMapping
    public ResponseCreatePortfolio createPortfolio(
        @RequestParam MultipartFile file,
        @RequestParam String portfolioMemo,
        @RequestParam String fileName,
        @RequestParam long userPk,
        @RequestParam int portfolioCategoryPk
    ) {
        return portfolioService
            .createPortfolio(file, portfolioMemo, fileName,userPk, portfolioCategoryPk);
    }

    @GetMapping("/list")
    public void findPortfolioList() {}

    @GetMapping
    public void findPortfolio() {}

    @PatchMapping
    public void updatePortfolio() {}

    @DeleteMapping
    public void deletePortfolio() {}
}
