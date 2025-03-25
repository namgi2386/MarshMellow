package com.gbh.gbh_mm.household.service;

import com.gbh.gbh_mm.household.model.dto.DateGroupDto;
import com.gbh.gbh_mm.household.model.dto.HouseholdDetailDto;
import com.gbh.gbh_mm.household.model.entity.Household;
import com.gbh.gbh_mm.household.model.entity.HouseholdCategory;
import com.gbh.gbh_mm.household.model.entity.HouseholdClassificationCategory;
import com.gbh.gbh_mm.household.model.entity.HouseholdDetailCategory;
import com.gbh.gbh_mm.household.model.enums.HouseholdClassificationEnum;
import com.gbh.gbh_mm.household.model.vo.request.RequestCreateHousehold;
import com.gbh.gbh_mm.household.model.vo.request.RequestFindHousehold;
import com.gbh.gbh_mm.household.model.vo.request.RequestFindHouseholdList;
import com.gbh.gbh_mm.household.model.vo.response.ResponseCreateHousehold;
import com.gbh.gbh_mm.household.model.vo.response.ResponseFindHousehold;
import com.gbh.gbh_mm.household.model.vo.response.ResponseFindHouseholdList;
import com.gbh.gbh_mm.household.repo.HouseholdCategoryRepository;
import com.gbh.gbh_mm.household.repo.HouseholdClassificationCategoryRepository;
import com.gbh.gbh_mm.household.repo.HouseholdDetailCategoryRepository;
import com.gbh.gbh_mm.household.repo.AiCategoryRepository;
import com.gbh.gbh_mm.household.repo.HouseholdRepository;
import com.gbh.gbh_mm.user.model.entity.User;
import com.gbh.gbh_mm.user.repo.UserRepository;
import jakarta.persistence.EntityNotFoundException;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import lombok.AllArgsConstructor;
import org.modelmapper.ModelMapper;
import org.modelmapper.convention.MatchingStrategies;
import org.springframework.stereotype.Service;

@Service
@AllArgsConstructor
public class HouseholdServiceImpl implements HouseholdService {
    private final HouseholdRepository householdRepository;
    private final HouseholdCategoryRepository householdCategoryRepository;
    private final HouseholdDetailCategoryRepository householdDetailCategoryRepository;
    private final HouseholdClassificationCategoryRepository householdClassificationCategoryRepository;
    private final AiCategoryRepository aiCategoryRepository;
    private final UserRepository userRepository;

    private final ModelMapper mapper;

    @Override
    public ResponseFindHouseholdList findHouseholdList(RequestFindHouseholdList request) {
        List<Household> householdList = householdRepository
            .findAllByTradeDateBetweenAndUser_UserPkOrderByTradeDateAsc
                (request.getStartDate(), request.getEndDate(), request.getUserPk());

        long totalIncome = householdList.stream()
            .filter(h -> h.getHouseholdClassificationCategory()
                .getHouseholdClassificationEnum().equals(HouseholdClassificationEnum.DEPOSIT))
            .mapToLong(Household::getHouseholdAmount)
            .sum();

        long totalExpenditure = householdList.stream()
            .filter(h -> h.getHouseholdClassificationCategory()
                .getHouseholdClassificationEnum().equals(HouseholdClassificationEnum.WITHDRAWAL))
            .mapToLong(Household::getHouseholdAmount)
            .sum();

        Map<String, List<HouseholdDetailDto>> grouped = householdList.stream()
            .collect(Collectors.groupingBy(Household::getTradeDate,
                Collectors.mapping(h -> {
                    HouseholdDetailDto householdDetailDto = HouseholdDetailDto.builder()
                        .tradeName(h.getTradeName())
                        .tradeDate(h.getTradeDate())
                        .tradeTime(h.getTradeTime())
                        .householdAmount(h.getHouseholdAmount())
                        .paymentMethod(h.getPaymentMethod())
                        .paymentCancelYn(h.getPaymentCancelYn())
                        .classification(h.getHouseholdClassificationCategory()
                            .getHouseholdClassificationEnum())
                        .build();

                    return householdDetailDto;
                }, Collectors.toList())
            ));

        List<DateGroupDto> households = grouped.entrySet().stream()
            .sorted((a, b) -> b.getKey().compareTo(a.getKey()))
            .map(entry -> {
                DateGroupDto dto = DateGroupDto.builder()
                    .date(entry.getKey())
                    .list(entry.getValue())
                    .build();

                return dto;
            })
            .collect(Collectors.toList());

        ResponseFindHouseholdList response = ResponseFindHouseholdList.builder()
            .totalIncome(totalIncome)
            .totalExpenditure(totalExpenditure)
            .householdList(households)
            .build();

        return response;
    }

    @Override
    public ResponseCreateHousehold createHousehold(RequestCreateHousehold request) {
        mapper.getConfiguration().setMatchingStrategy(MatchingStrategies.STRICT);
        Household household = mapper.map(request, Household.class);
        User user = userRepository.findById(request.getUserPk())
            .orElseThrow(() -> new EntityNotFoundException("존재하지 않는 회원"));
        HouseholdClassificationCategory householdClassificationCategory =
            householdClassificationCategoryRepository
                .findByHouseholdClassificationEnum(request.getHouseholdClassification());
        HouseholdCategory householdCategory = householdCategoryRepository
            .findById(request.getHouseholdCategoryPk())
            .orElseThrow(() -> new EntityNotFoundException("존재하지 않는 분류"));
        HouseholdDetailCategory householdDetailCategory =
            householdDetailCategoryRepository
                .findByHouseholdDetailCategory(request.getHouseholdDetailCategoryName());

        household.setUser(user);
        household.setHouseholdClassificationCategory(householdClassificationCategory);
        household.setHouseholdCategory(householdCategory);
        household.setHouseholdDetailCategory(householdDetailCategory);
        household.setPaymentCancelYn("N");

        Household savedHousehold = householdRepository.save(household);


        ResponseCreateHousehold response = ResponseCreateHousehold.builder()
            .householdPk(savedHousehold.getHouseholdPk())
            .tradeName(savedHousehold.getTradeName())
            .tradeDate(savedHousehold.getTradeDate())
            .tradeTime(savedHousehold.getTradeTime())
            .householdAmount(savedHousehold.getHouseholdAmount())
            .householdMemo(savedHousehold.getHouseholdMemo())
            .paymentMethod(savedHousehold.getPaymentMethod())
            .paymentCancelYn(savedHousehold.getPaymentCancelYn())
            .exceptedBudgetYn(savedHousehold.getExceptedBudgetYn())
            .householdCategory(savedHousehold.getHouseholdCategory().getHouseholdCategoryName())
            .householdDetailCategory
                (savedHousehold.getHouseholdDetailCategory().getHouseholdDetailCategory())
            .householdClassificationCategory
                (savedHousehold.getHouseholdClassificationCategory().getHouseholdClassificationEnum())
            .build();

        return response;
    }

    @Override
    public ResponseFindHousehold findHousehold(RequestFindHousehold request) {
        Household household = householdRepository.findById(request.getHouseholdPk())
            .orElseThrow(() -> new EntityNotFoundException("존재하지 않는 가계부입니다."));

        ResponseFindHousehold response = ResponseFindHousehold.builder()
            .householdId(household.getHouseholdPk())
            .tradeName(household.getTradeName())
            .tradeDate(household.getTradeDate())
            .tradeTime(household.getTradeTime())
            .householdAmount(household.getHouseholdAmount())
            .householdMemo(household.getHouseholdMemo())
            .paymentCancelYn(household.getPaymentCancelYn())
            .exceptedBudgetYn(household.getExceptedBudgetYn())
            .householdCategory(household.getHouseholdCategory().getHouseholdCategoryName())
            .householdDetailCategory
                (household.getHouseholdDetailCategory().getHouseholdDetailCategory())
            .householdClassification
                (household.getHouseholdClassificationCategory().getHouseholdClassificationEnum())
            .build();

        return response;
    }
}
