package com.gbh.gbh_mm.portfolio.repo;

import com.gbh.gbh_mm.portfolio.model.entity.PortfolioCategory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface PortfolioCategoryRepository extends JpaRepository<PortfolioCategory, Integer> {

}
