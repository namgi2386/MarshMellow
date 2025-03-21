package com.gbh.gbh_mm.asset.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.gbh.gbh_mm.api.CardAPI;
import com.gbh.gbh_mm.api.DemandDepositAPI;
import com.gbh.gbh_mm.api.DepositAPI;
import com.gbh.gbh_mm.api.LoanAPI;
import com.gbh.gbh_mm.api.SavingsAPI;
import com.gbh.gbh_mm.asset.model.dto.CardListDto;
import com.gbh.gbh_mm.asset.model.dto.DemandDepositListDto;
import com.gbh.gbh_mm.asset.model.dto.DepositListDto;
import com.gbh.gbh_mm.asset.model.dto.LoanListDto;
import com.gbh.gbh_mm.asset.model.dto.SavingsListDto;
import com.gbh.gbh_mm.asset.model.vo.request.RequestFindAssetList;
import com.gbh.gbh_mm.asset.model.vo.response.ResponseFindAssetList;
import com.gbh.gbh_mm.finance.card.vo.request.RequestFindUserCardList;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import lombok.AllArgsConstructor;
import org.modelmapper.ModelMapper;
import org.modelmapper.convention.MatchingStrategies;
import org.springframework.stereotype.Service;

@Service
@AllArgsConstructor
public class AssetServiceImpl implements AssetService {

    private final DemandDepositAPI demandDepositAPI;
    private final CardAPI cardAPI;
    private final LoanAPI loanAPI;
    private final SavingsAPI savingsAPI;
    private final DepositAPI depositAPI;

    private final ModelMapper mapper;

    @Override
    public ResponseFindAssetList findAssetList(RequestFindAssetList request) {
        mapper.getConfiguration().setMatchingStrategy(MatchingStrategies.STRICT);

        ResponseFindAssetList response = new ResponseFindAssetList();

        try {
            Map<String, Object> responseCardData =
                cardAPI.findUserCardList(request.getUserKey());
            Map<String, Object> responseDepositDemandData =
                demandDepositAPI.findDemandDepositAccountList(request.getUserKey());
            Map<String, Object> responseLoanData =
                loanAPI.findAccountList(request.getUserKey());
            Map<String, Object> responseSavingsData =
                savingsAPI.findAccountList(request.getUserKey());
            Map<String, Object> responseDepositData =
                depositAPI.findAccountList(request.getUserKey());

            Map<String, Object> cardApiData =
                (Map<String, Object>) responseCardData.get("apiResponse");
            Map<String, Object> depositDemandApiData =
                (Map<String, Object>) responseDepositDemandData.get("apiResponse");
            Map<String, Object> loanApiData =
                (Map<String, Object>) responseLoanData.get("apiResponse");
            Map<String, Object> savingsApiData =
                (Map<String, Object>) responseSavingsData.get("apiResponse");
            Map<String, Object> depositApiData =
                (Map<String, Object>) responseDepositData.get("apiResponse");

            System.out.println(depositApiData);

            List<Map<String, Object>> responseCardList =
                (List<Map<String, Object>>) cardApiData.get("REC");
            List<Map<String, Object>> responseDemandDepositList =
                (List<Map<String, Object>>) depositDemandApiData.get("REC");
            List<Map<String, Object>> responseLoanList =
                (List<Map<String, Object>>) loanApiData.get("REC");
            Map<String, Object> responseSavingsList =
                (Map<String, Object>) savingsApiData.get("REC");
            List<Map<String, Object>> savings =
                (List<Map<String, Object>>) responseSavingsList.get("list");
            Map<String, Object> responseDepositList =
                (Map<String, Object>) depositApiData.get("REC");
            List<Map<String, Object>> deposits =
                (List<Map<String, Object>>) responseDepositList.get("list");

            List<CardListDto> cardListDtos = responseCardList.stream()
                .map(cardMap -> mapper.map(cardMap, CardListDto.class))
                .collect(Collectors.toList());
            List<DemandDepositListDto> demandDepositListDtos = responseDemandDepositList.stream()
                .map(demandDepositMap ->
                    mapper.map(demandDepositMap, DemandDepositListDto.class))
                .collect(Collectors.toList());
            List<LoanListDto> loanListDtos = responseLoanList.stream()
                .map(loanMap -> mapper.map(loanMap, LoanListDto.class))
                .collect(Collectors.toList());
            List<SavingsListDto> savingsListDtos = savings.stream()
                .map(savingsMap -> mapper.map(savingsMap, SavingsListDto.class))
                .collect(Collectors.toList());
            List<DepositListDto> depositListDtos = deposits.stream()
                .map(depositMap -> mapper.map(depositMap, DepositListDto.class))
                .collect(Collectors.toList());

            response.setCardList(cardListDtos);
            response.setDemandDepositList(demandDepositListDtos);
            response.setLoanList(loanListDtos);
            response.setSavingsList(savingsListDtos);
            response.setDepositList(depositListDtos);
        } catch (JsonProcessingException e) {
            throw new RuntimeException(e);
        }
        return response;
    }
}
