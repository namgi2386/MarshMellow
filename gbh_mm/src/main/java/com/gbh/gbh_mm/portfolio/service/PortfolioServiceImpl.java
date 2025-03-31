package com.gbh.gbh_mm.portfolio.service;

import com.gbh.gbh_mm.common.exception.CustomException;
import com.gbh.gbh_mm.common.exception.ErrorCode;
import com.gbh.gbh_mm.portfolio.model.dto.PortfolioCategoryDto;
import com.gbh.gbh_mm.portfolio.model.entity.Portfolio;
import com.gbh.gbh_mm.portfolio.model.entity.PortfolioCategory;
import com.gbh.gbh_mm.portfolio.model.request.RequestCreateCategory;
import com.gbh.gbh_mm.portfolio.model.response.ResponseCreateCategory;
import com.gbh.gbh_mm.portfolio.repo.PortfolioCategoryRepository;
import com.gbh.gbh_mm.portfolio.repo.PortfolioRepository;
import com.gbh.gbh_mm.user.model.entity.User;
import com.gbh.gbh_mm.user.repo.UserRepository;
import java.util.List;
import java.util.stream.Collectors;
import lombok.AllArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.stereotype.Service;

@Service
@AllArgsConstructor
public class PortfolioServiceImpl implements PortfolioService {
    private final PortfolioRepository portfolioRepository;
    private final PortfolioCategoryRepository portfolioCategoryRepository;
    private final UserRepository userRepository;
    private final ModelMapper mapper;

    @Override
    public ResponseCreateCategory createCategory(RequestCreateCategory request) {
        User user = userRepository.findByUserPk(request.getUserPk())
            .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        PortfolioCategory portfolioCategory = PortfolioCategory.builder()
            .portfolioCategoryMemo(request.getCategoryMemo())
            .portfolioCategoryName(request.getCategoryName())
            .user(user)
            .build();

        portfolioCategoryRepository.save(portfolioCategory);
        List<PortfolioCategory> portfolioCategoryList = portfolioCategoryRepository.findAll();

        List<PortfolioCategoryDto> portfolioCategoryDtoList = portfolioCategoryList.stream()
            .map(p -> mapper.map(p, PortfolioCategoryDto.class))
            .collect(Collectors.toList());

        ResponseCreateCategory response = ResponseCreateCategory.builder()
            .portfolioCategoryList(portfolioCategoryDtoList)
            .build();

        return response;
    }
}
