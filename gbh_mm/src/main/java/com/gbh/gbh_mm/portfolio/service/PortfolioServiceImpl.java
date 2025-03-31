package com.gbh.gbh_mm.portfolio.service;

import com.gbh.gbh_mm.common.exception.CustomException;
import com.gbh.gbh_mm.common.exception.ErrorCode;
import com.gbh.gbh_mm.portfolio.model.dto.PortfolioCategoryDto;
import com.gbh.gbh_mm.portfolio.model.entity.Portfolio;
import com.gbh.gbh_mm.portfolio.model.entity.PortfolioCategory;
import com.gbh.gbh_mm.portfolio.model.request.RequestCreateCategory;
import com.gbh.gbh_mm.portfolio.model.request.RequestDeleteCategory;
import com.gbh.gbh_mm.portfolio.model.request.RequestFindCategoryList;
import com.gbh.gbh_mm.portfolio.model.request.RequestUpdateCategory;
import com.gbh.gbh_mm.portfolio.model.response.ResponseCreateCategory;
import com.gbh.gbh_mm.portfolio.model.response.ResponseCreatePortfolio;
import com.gbh.gbh_mm.portfolio.model.response.ResponseDeleteCategory;
import com.gbh.gbh_mm.portfolio.model.response.ResponseFindCategoryList;
import com.gbh.gbh_mm.portfolio.model.response.ResponseUpdateCategory;
import com.gbh.gbh_mm.portfolio.repo.PortfolioCategoryRepository;
import com.gbh.gbh_mm.portfolio.repo.PortfolioRepository;
import com.gbh.gbh_mm.s3.S3Component;
import com.gbh.gbh_mm.user.model.entity.User;
import com.gbh.gbh_mm.user.repo.UserRepository;
import jakarta.persistence.EntityNotFoundException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;
import lombok.AllArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
@AllArgsConstructor
public class PortfolioServiceImpl implements PortfolioService {
    private final PortfolioRepository portfolioRepository;
    private final PortfolioCategoryRepository portfolioCategoryRepository;
    private final UserRepository userRepository;
    private final ModelMapper mapper;
    private final S3Component s3Component;

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

    @Override
    public ResponseFindCategoryList findCategoryList(RequestFindCategoryList request) {
        List<PortfolioCategory> portfolioCategoryList = portfolioCategoryRepository.findAll();

        List<PortfolioCategoryDto> portfolioCategoryDtoList = portfolioCategoryList.stream()
            .map(p -> mapper.map(p, PortfolioCategoryDto.class))
            .collect(Collectors.toList());

        ResponseFindCategoryList response = ResponseFindCategoryList.builder()
            .portfolioCategoryList(portfolioCategoryDtoList)
            .build();

        return response;
    }

    @Override
    public ResponseDeleteCategory deleteCategory(RequestDeleteCategory request) {
        try {
            portfolioRepository.deleteById(request.getCategoryPk());

            ResponseDeleteCategory response = ResponseDeleteCategory.builder()
                .message("SUCCESS")
                .build();

            return response;

        } catch (Exception e) {
            ResponseDeleteCategory response = ResponseDeleteCategory.builder()
                .message("FAIL")
                .build();

            return response;
        }
    }

    @Override
    public ResponseUpdateCategory updateCategory(RequestUpdateCategory request) {
        PortfolioCategory portfolioCategory = portfolioCategoryRepository
            .findById(request.getCategoryPk())
            .orElseThrow(() -> new EntityNotFoundException("존재하지 않는 카테고리"));

        if (request.getCategoryMemo() != null) {
            portfolioCategory.setPortfolioCategoryMemo(request.getCategoryMemo());
        }

        if (request.getCategoryName() != null) {
            portfolioCategory.setPortfolioCategoryName(request.getCategoryName());
        }

        portfolioCategoryRepository.save(portfolioCategory);

        ResponseUpdateCategory response = mapper.map(portfolioCategory, ResponseUpdateCategory.class);

        return response;
    }

    @Override
    public ResponseCreatePortfolio createPortfolio(MultipartFile file, String portfolioMemo,
        String fileName, long userPk, int portfolioCategoryPk) {
        User user = userRepository.findByUserPk(userPk)
            .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));
        PortfolioCategory portfolioCategory = portfolioCategoryRepository
            .findById(portfolioCategoryPk)
            .orElseThrow(() -> new EntityNotFoundException("존재하지 않는 카테고리"));

        String fileUrl = s3Component.uploadFile(file);

        LocalDateTime now = LocalDateTime.now();
        String date = now.format(DateTimeFormatter.ofPattern("yyyyMMdd"));
        String time = now.format(DateTimeFormatter.ofPattern("HHmmss"));

        Portfolio portfolio = Portfolio.builder()
            .fileUrl(fileUrl)
            .fileName(fileName)
            .createDate(date)
            .createTime(time)
            .originFileName(file.getOriginalFilename())
            .fileName(fileName)
            .portfolioMemo(portfolioMemo)
            .user(user)
            .portfolioCategory(portfolioCategory)
            .build();

        Portfolio savedPortfolio = portfolioRepository.save(portfolio);

        PortfolioCategoryDto portfolioCategoryDto =
            mapper.map(savedPortfolio.getPortfolioCategory(), PortfolioCategoryDto.class);

        ResponseCreatePortfolio response = mapper.map(savedPortfolio, ResponseCreatePortfolio.class);
        response.setPortfolioCategory(portfolioCategoryDto);

        return response;
    }
}
