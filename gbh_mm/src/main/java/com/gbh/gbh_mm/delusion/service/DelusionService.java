package com.gbh.gbh_mm.delusion.service;

import com.gbh.gbh_mm.asset.model.vo.response.ResponseFindAssetList;
import com.gbh.gbh_mm.asset.service.AssetService;
import com.gbh.gbh_mm.delusion.model.response.AvailableAmountResponseDto;
import com.gbh.gbh_mm.delusion.model.response.AverageSpendingResponseDto;
import com.gbh.gbh_mm.household.model.dto.DateGroupDto;
import com.gbh.gbh_mm.household.model.dto.HouseholdDetailDto;
import com.gbh.gbh_mm.household.model.entity.Household;
import com.gbh.gbh_mm.household.model.vo.request.RequestSearchHousehold;
import com.gbh.gbh_mm.household.model.vo.response.ResponseSearchHousehold;
import com.gbh.gbh_mm.user.model.entity.CustomUserDetails;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@AllArgsConstructor
@Slf4j
public class DelusionService {

    private AssetService assetService;

    public AvailableAmountResponseDto getAvailableAmount(CustomUserDetails customUserDetails) {

        ResponseFindAssetList findAssetList = assetService.findAssetListWithNoEncrypt(customUserDetails);
        return AvailableAmountResponseDto.builder()
                .availableAmount(findAssetList.getDemandDepositData().getTotalAmount())
                .build();
    }

    public AverageSpendingResponseDto getAverageSpending(CustomUserDetails customUserDetails) {
            List<Household> householdList = householdRepository.searchHousehold
                    (request.getStartDate(), request.getEndDate(), customUserDetails.getUserPk(),
                            request.getKeyword());

            Map<String, List<HouseholdDetailDto>> grouped = householdList.stream()
                    .collect(Collectors.groupingBy(Household::getTradeDate,
                            Collectors.mapping(h -> {
                                HouseholdDetailDto householdDetailDto = HouseholdDetailDto.builder()
                                        .householdPk(h.getHouseholdPk())
                                        .tradeName(h.getTradeName())
                                        .tradeDate(h.getTradeDate())
                                        .tradeTime(h.getTradeTime())
                                        .householdAmount(h.getHouseholdAmount())
                                        .paymentMethod(h.getPaymentMethod())
                                        .paymentCancelYn(h.getPaymentCancelYn())
                                        .householdCategory(h.getHouseholdDetailCategory()
                                                .getHouseholdCategory()
                                                .getHouseholdCategoryName())
                                        .householdClassificationCategory(h.getHouseholdClassificationCategory())
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

            ResponseSearchHousehold response = ResponseSearchHousehold.builder()
                    .householdList(households)
                    .build();

            return response;
        }
        return null;
    }
}
