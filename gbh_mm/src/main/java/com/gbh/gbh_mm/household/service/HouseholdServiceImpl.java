package com.gbh.gbh_mm.household.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.gbh.gbh_mm.api.CardAPI;
import com.gbh.gbh_mm.api.DemandDepositAPI;
import com.gbh.gbh_mm.finance.card.vo.request.RequestFindCardTransactionList;
import com.gbh.gbh_mm.finance.demandDeposit.vo.request.RequestFindTransactionList;
import com.gbh.gbh_mm.household.model.dto.CardDto;
import com.gbh.gbh_mm.household.model.dto.DateGroupDto;
import com.gbh.gbh_mm.household.model.dto.DemandDepositDto;
import com.gbh.gbh_mm.household.model.dto.HouseHoldDto;
import com.gbh.gbh_mm.household.model.dto.HouseholdDetailDto;
import com.gbh.gbh_mm.household.model.entity.Household;
import com.gbh.gbh_mm.household.model.entity.HouseholdCategory;
import com.gbh.gbh_mm.household.model.entity.HouseholdDetailCategory;
import com.gbh.gbh_mm.household.model.enums.HouseholdClassificationEnum;
import com.gbh.gbh_mm.household.model.vo.request.RequestCreateHousehold;
import com.gbh.gbh_mm.household.model.vo.request.RequestDeleteHousehold;
import com.gbh.gbh_mm.household.model.vo.request.RequestFindHousehold;
import com.gbh.gbh_mm.household.model.vo.request.RequestFindHouseholdList;
import com.gbh.gbh_mm.household.model.vo.request.RequestFindTransactionDataList;
import com.gbh.gbh_mm.household.model.vo.request.RequestUpdateHousehold;
import com.gbh.gbh_mm.household.model.vo.response.RequestCreateHouseholdList;
import com.gbh.gbh_mm.household.model.vo.response.ResponseCreateHousehold;
import com.gbh.gbh_mm.household.model.vo.response.ResponseCreateHouseholdList;
import com.gbh.gbh_mm.household.model.vo.response.ResponseDeleteHousehold;
import com.gbh.gbh_mm.household.model.vo.response.ResponseFindHousehold;
import com.gbh.gbh_mm.household.model.vo.response.ResponseFindHouseholdList;
import com.gbh.gbh_mm.household.model.vo.response.ResponseFindTransactionDataList;
import com.gbh.gbh_mm.household.model.vo.response.ResponseUpdateHousehold;
import com.gbh.gbh_mm.household.repo.HouseholdCategoryRepository;
import com.gbh.gbh_mm.household.repo.HouseholdDetailCategoryRepository;
import com.gbh.gbh_mm.household.repo.AiCategoryRepository;
import com.gbh.gbh_mm.household.repo.HouseholdRepository;
import com.gbh.gbh_mm.user.model.entity.User;
import com.gbh.gbh_mm.user.repo.UserRepository;
import jakarta.persistence.EntityNotFoundException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;
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
    private final AiCategoryRepository aiCategoryRepository;
    private final UserRepository userRepository;

    private final CardAPI cardAPI;
    private final DemandDepositAPI demandDepositAPI;

    private final ModelMapper mapper;

    @Override
    public ResponseFindHouseholdList findHouseholdList(RequestFindHouseholdList request) {
        List<Household> householdList = householdRepository
            .findAllByTradeDateBetweenAndUser_UserPkOrderByTradeDateAsc
                (request.getStartDate(), request.getEndDate(), request.getUserPk());

        long totalIncome = householdList.stream()
            .filter(h -> h.getHouseholdClassificationCategory()
                .equals(HouseholdClassificationEnum.DEPOSIT))
            .mapToLong(Household::getHouseholdAmount)
            .sum();

        long totalExpenditure = householdList.stream()
            .filter(h -> h.getHouseholdClassificationCategory()
                .equals(HouseholdClassificationEnum.WITHDRAWAL))
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
                        .classification(h.getHouseholdClassificationCategory())
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
        HouseholdDetailCategory householdDetailCategory =
            householdDetailCategoryRepository
                .findByHouseholdDetailCategory(request.getHouseholdDetailCategoryName());

        household.setUser(user);
        household.setHouseholdClassificationCategory(request.getHouseholdClassification());
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
            .householdCategory(savedHousehold.getHouseholdDetailCategory()
                .getHouseholdCategory().getHouseholdCategoryName())
            .householdDetailCategory
                (savedHousehold.getHouseholdDetailCategory().getHouseholdDetailCategory())
            .householdClassificationCategory
                (savedHousehold.getHouseholdClassificationCategory())
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
            .householdCategory(household.getHouseholdDetailCategory()
                .getHouseholdCategory().getHouseholdCategoryName())
            .householdDetailCategory
                (household.getHouseholdDetailCategory().getHouseholdDetailCategory())
            .householdClassification
                (household.getHouseholdClassificationCategory())
            .build();

        return response;
    }

    @Override
    public ResponseUpdateHousehold updateHousehold(RequestUpdateHousehold request) {
        Household household = householdRepository.findById(request.getHouseholdPk())
            .orElseThrow(() -> new EntityNotFoundException("존재하지 않는 가계부"));

        if (request.getHouseholdAmount() != null) {
            household.setHouseholdAmount(request.getHouseholdAmount());
        }

        if (request.getExceptedBudgetYn() != null) {
            household.setExceptedBudgetYn(request.getExceptedBudgetYn());
        }

        if (request.getHouseholdMemo() != null) {
            household.setHouseholdMemo(request.getHouseholdMemo());
        }

        householdRepository.save(household);

        mapper.getConfiguration().setMatchingStrategy(MatchingStrategies.STRICT);
        ResponseUpdateHousehold response = mapper.map(household, ResponseUpdateHousehold.class);

        response.setHouseholdCategory(household.getHouseholdDetailCategory()
            .getHouseholdCategory().getHouseholdCategoryName());
        response.setHouseholdDetailCategory
            (household.getHouseholdDetailCategory().getHouseholdDetailCategory());
        response.setHouseholdClassificationCategory
            (household.getHouseholdClassificationCategory());

        return response;
    }

    @Override
    public ResponseDeleteHousehold deleteHousehold(RequestDeleteHousehold request) {
        ResponseDeleteHousehold response = new ResponseDeleteHousehold();
        try {
            Optional<Household> household = householdRepository.findById(request.getHouseholdPk());
            householdRepository.delete(household.get());
            response.setMessage("삭제 성공");
        } catch (Exception e) {
            response.setMessage("삭제 실패");
        }

        return response;
    }

    @Override
    public ResponseFindTransactionDataList findTransactionDataList(
        RequestFindTransactionDataList request) {
        mapper.getConfiguration().setMatchingStrategy(MatchingStrategies.STRICT);

        List<Household> householdList = householdRepository
            .findTop2ByUser_UserPkOrderByTradeDateDesc(request.getUserPk());

        LocalDate currentDate = LocalDate.now();

        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMdd");
        String currentString = currentDate.format(formatter);
        String lastDate = "";
        if (householdList.size() > 0) {
            /* 마지막일 ~ 현재일 */
            lastDate = householdList.getFirst().getTradeDate();
        } else {
            /* 전부 조회 */
            lastDate = "20200101";
        }

        List<Household> houseHolds = new ArrayList<>();

        try {
            Optional<User> user = userRepository.findById(request.getUserPk());

            Map<String, Object> cardApiData =
                cardAPI.findUserCardList(request.getUserKey());
            Map<String, Object> cardResponseData =
                (Map<String, Object>) cardApiData.get("apiResponse");
            List<Map<String, Object>> cardRecData =
                (List<Map<String, Object>>) cardResponseData.get("REC");

            List<CardDto> cardDtoList = new ArrayList<>();
            for (Map<String, Object> cardRecDatum : cardRecData) {
                CardDto cardDto = mapper.map(cardRecDatum, CardDto.class);
                cardDtoList.add(cardDto);
            }

            Map<String, Object> demandDepositApiData =
                demandDepositAPI.findDemandDepositAccountList(request.getUserKey());
            Map<String, Object> demandDepositReponseData =
                (Map<String, Object>) demandDepositApiData.get("apiResponse");
            List<Map<String, Object>> demandDepositRecData =
                (List<Map<String, Object>>) demandDepositReponseData.get("REC");

            /* 조회한 카드 목록에서 하나씩 분리 */
            for (CardDto card : cardDtoList) {
                RequestFindCardTransactionList requestCardTransaction =
                    new RequestFindCardTransactionList();

                requestCardTransaction.setCardNo(card.getCardNo());
                requestCardTransaction.setCvc(card.getCvc());
                requestCardTransaction.setEndDate(currentString);
                requestCardTransaction.setStartDate(lastDate);
                requestCardTransaction.setUserKey(request.getUserKey());

                /* 해당 카드 거래내역 조회 */
                Map<String, Object> cardTransactionApiData =
                    cardAPI.findTransactionList(requestCardTransaction);

                Map<String, Object> cardTransactionReponseData =
                    (Map<String, Object>) cardTransactionApiData.get("apiResponse");
                Map<String, Object> cardTransactionRecData =
                    (Map<String, Object>) cardTransactionReponseData.get("REC");
                List<Map<String, Object>> cardTransactionList =
                    (List<Map<String, Object>>) cardTransactionRecData.get("transactionList");


                /* 해당 카드 거래내역 매핑 */
                for (Map<String, Object> cardTransactionRecDatum : cardTransactionList) {
                    /* 해당 카드 거래내역 Response에 추가 */
                    Household household = Household.builder()
                        .tradeName((String) cardTransactionRecDatum.get("merchantName"))
                        .tradeDate((String) cardTransactionRecDatum.get("transactionDate"))
                        .tradeTime((String) cardTransactionRecDatum.get("transactionTime"))
                        .householdAmount(
                            Integer.parseInt(
                                (String) cardTransactionRecDatum.get("transactionBalance")))
                        .paymentMethod(card.getCardName())
                        .exceptedBudgetYn("N")
                        .householdClassificationCategory(HouseholdClassificationEnum.WITHDRAWAL)
                        .user(user.get())
                        .build();
                    if (cardTransactionRecDatum.get("cardStatus").equals("승인")) {
                        household.setPaymentCancelYn("N");
                    } else {
                        household.setPaymentCancelYn("Y");
                    }
                    houseHolds.add(household);
                }
            }

            List<DemandDepositDto> demandDepositDtoList = new ArrayList<>();
            for (Map<String, Object> demandDepositRecDatum : demandDepositRecData) {
                DemandDepositDto DemandDepositDto =
                    mapper.map(demandDepositRecDatum, DemandDepositDto.class);
                demandDepositDtoList.add(DemandDepositDto);
            }

            for (DemandDepositDto demandDepositDto : demandDepositDtoList) {
                RequestFindTransactionList requestFindTransactionList =
                    RequestFindTransactionList.builder()
                        .accountNo(demandDepositDto.getAccountNo())
                        .startDate(lastDate)
                        .endDate(currentString)
                        .transactionType("A")
                        .orderByType("ASC")
                        .userKey(request.getUserKey())
                        .build();

                Map<String, Object> demandDepositTransactionData =
                    demandDepositAPI.findTransactionList(requestFindTransactionList);
                Map<String, Object> demandDepositTransactionApiResponse =
                    (Map<String, Object>) demandDepositTransactionData.get("apiResponse");
                Map<String, Object> demandDepositTransactionRecData =
                    (Map<String, Object>) demandDepositTransactionApiResponse.get("REC");
                List<Map<String, Object>> demandDepositTransactionList =
                    (List<Map<String, Object>>) demandDepositTransactionRecData.get("list");

                for (Map<String, Object> demandDepositTransaction : demandDepositTransactionList) {
                    Household household = Household.builder()
                        .tradeName((String) demandDepositTransaction.get("transactionSummary"))
                        .tradeDate((String) demandDepositTransaction.get("transactionDate"))
                        .tradeTime((String) demandDepositTransaction.get("transactionTime"))
                        .householdAmount(
                            Integer.parseInt(
                                (String) demandDepositTransaction.get("transactionBalance")))
                        .paymentMethod(demandDepositDto.getAccountName())
                        .exceptedBudgetYn("N")
                        .paymentCancelYn("N")
                        .user(user.get())
                        .build();

                    if (demandDepositTransaction.get("transactionType").equals("1")) {
                        household.setHouseholdClassificationCategory(
                            HouseholdClassificationEnum.DEPOSIT);
                    } else {
                        household.setHouseholdClassificationCategory(
                            HouseholdClassificationEnum.TRANSFER);
                    }
                    houseHolds.add(household);
                }

            }
            ResponseFindTransactionDataList responseHousehold = new ResponseFindTransactionDataList();
            responseHousehold.setHouseholdList(houseHolds);

            return responseHousehold;
        } catch (JsonProcessingException e) {

            throw new RuntimeException(e);
        }
    }

    @Override
    public ResponseCreateHouseholdList createHouseholdList(RequestCreateHouseholdList request) {

        List<HouseHoldDto> householdDtoList = request.getTest();
        List<Household> householdList = new ArrayList<>();
        for (HouseHoldDto householdDto : householdDtoList) {
            String category = householdDto.getCategory().replaceAll("\\s+", "");;

            HouseholdDetailCategory householdDetailCategory =
                householdDetailCategoryRepository
                    .findByHouseholdDetailCategory(category);

            Household household = Household.builder()
                .tradeName(householdDto.getTradeName())
                .tradeDate(householdDto.getTradeDate())
                .tradeTime(householdDto.getTradeTime())
                .householdAmount(householdDto.getHouseholdAmount())
                .paymentMethod(householdDto.getPaymentMethod())
                .paymentCancelYn(householdDto.getPaymentCancelYn())
                .exceptedBudgetYn(householdDto.getExceptedBudgetYn())
                .user(householdDto.getUser())
                .householdDetailCategory(householdDetailCategory)
                .householdClassificationCategory(householdDto.getHouseholdClassificationCategory())
                .build();
            householdList.add(household);
        }

        householdRepository.saveAll(householdList);

        return null;
    }
}
