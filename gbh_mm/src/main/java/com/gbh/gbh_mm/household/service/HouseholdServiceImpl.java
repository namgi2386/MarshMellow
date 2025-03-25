package com.gbh.gbh_mm.household.service;

import com.gbh.gbh_mm.household.model.dto.DateGroupDto;
import com.gbh.gbh_mm.household.model.dto.HouseholdDetailDto;
import com.gbh.gbh_mm.household.model.entity.Household;
import com.gbh.gbh_mm.household.model.enums.HouseholdClassificationEnum;
import com.gbh.gbh_mm.household.model.vo.request.RequestFindHouseholdList;
import com.gbh.gbh_mm.household.model.vo.response.ResponseFindHouseholdList;
import com.gbh.gbh_mm.household.repo.HouseholdCategoryRepository;
import com.gbh.gbh_mm.household.repo.HouseholdClassificationCategoryRepository;
import com.gbh.gbh_mm.household.repo.HouseholdDetailCategoryRepository;
import com.gbh.gbh_mm.household.repo.AiCategoryRepository;
import com.gbh.gbh_mm.household.repo.HouseholdRepository;
import com.gbh.gbh_mm.user.repo.UserRepository;
import java.text.Collator;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import lombok.AllArgsConstructor;
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

    @Override
    public ResponseFindHouseholdList findHouseholdList(RequestFindHouseholdList request) {
        List<Household> householdList = householdRepository
            .findAllByDateStringBetweenAndUser_UserPkOrderByDateStringAsc
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
}
