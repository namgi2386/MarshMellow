package com.gbh.gbh_mm.portfolio.controller;

import com.gbh.gbh_mm.portfolio.model.entity.Portfolio;
import com.gbh.gbh_mm.portfolio.model.request.RequestCreateCategory;
import com.gbh.gbh_mm.portfolio.model.response.ResponseCreateCategory;
import com.gbh.gbh_mm.portfolio.service.PortfolioService;
import lombok.AllArgsConstructor;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

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
    public void findPortfolioCategoryList() {}

    @DeleteMapping("/category")
    public void deletePortfolioCategory() {}

    @PatchMapping("/category")
    public void updatePortfolioCategory() {}

    @PostMapping
    public void createPortfolio() {}

    @GetMapping("/list")
    public void findPortfolioList() {}

    @GetMapping
    public void findPortfolio() {}

    @PatchMapping
    public void updatePortfolio() {}

    @DeleteMapping
    public void deletePortfolio() {}
}
