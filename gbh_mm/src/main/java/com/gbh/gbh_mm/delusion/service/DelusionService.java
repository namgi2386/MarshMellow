package com.gbh.gbh_mm.delusion.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.gbh.gbh_mm.api.CardAPI;
import com.gbh.gbh_mm.api.DemandDepositAPI;
import com.gbh.gbh_mm.api.SavingsAPI;
import com.gbh.gbh_mm.asset.model.entity.*;
import com.gbh.gbh_mm.asset.model.vo.response.ResponseFindAssetList;
import com.gbh.gbh_mm.asset.service.AssetService;
import com.gbh.gbh_mm.delusion.response.AvailableAmountResponseDto;
import com.gbh.gbh_mm.delusion.response.AverageSpendingResponseDto;
import com.gbh.gbh_mm.finance.card.vo.request.RequestFindBilling;
import com.gbh.gbh_mm.finance.demandDeposit.vo.request.RequestFindTransactionList;
import com.gbh.gbh_mm.user.model.entity.CustomUserDetails;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.modelmapper.ModelMapper;
import org.modelmapper.convention.MatchingStrategies;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.util.*;

@Service
@AllArgsConstructor
@Slf4j
public class DelusionService {

    private final AssetService assetService;
    private final ModelMapper mapper;
    private final CardAPI cardAPI;
    private final DemandDepositAPI demandDepositAPI;
    private final SavingsAPI savingsAPI;

    public AvailableAmountResponseDto getAvailableAmount(CustomUserDetails customUserDetails) {

        ResponseFindAssetList findAssetList = assetService.findAssetListWithNoEncrypt(customUserDetails);
        return AvailableAmountResponseDto.builder()
                .availableAmount(findAssetList.getDemandDepositData().getTotalAmount())
                .build();
    }

    public AverageSpendingResponseDto getAverageSpending(CustomUserDetails customUserDetails) throws JsonProcessingException {

        mapper.getConfiguration().setMatchingStrategy(MatchingStrategies.STRICT);

        String userKey = customUserDetails.getUserKey();

        try {
            /* 목록 조회 API 호출 */
            Map<String, Object> responseCardData = cardAPI.findUserCardList(userKey);
            Map<String, Object> responseDepositDemandData = demandDepositAPI.findDemandDepositAccountList(userKey);
            Map<String, Object> responseSavingsData = savingsAPI.findAccountList(userKey);

            Map<String, Object> cardApiData = (Map<String, Object>) responseCardData.get("apiResponse");
            Map<String, Object> depositDemandApiData = (Map<String, Object>) responseDepositDemandData.get("apiResponse");
            Map<String, Object> savingsApiData = (Map<String, Object>) responseSavingsData.get("apiResponse");

            List<Map<String, Object>> responseCardList = (List<Map<String, Object>>) cardApiData.get("REC");
            List<Map<String, Object>> responseDemandDepositList = (List<Map<String, Object>>) depositDemandApiData.get("REC");
            Map<String, Object> responseSavingsList = (Map<String, Object>) savingsApiData.get("REC");
            List<Map<String, Object>> savings = (List<Map<String, Object>>) responseSavingsList.get("list");

            List<Card> cardList = responseCardList.stream()
                    .map(cardMap -> mapper.map(cardMap, Card.class))
                    .toList();

            List<DemandDeposit> demandDepositList = responseDemandDepositList.stream()
                    .map(demandDepositMap ->
                            mapper.map(demandDepositMap, DemandDeposit.class))
                    .toList();

            List<Savings> savingsList = savings.stream()
                    .map(map -> mapper.map(map, Savings.class))
                    .toList();

            Map<String, Long> monthlySpendingMap = new LinkedHashMap<>();

            DateTimeFormatter yyyyMM = DateTimeFormatter.ofPattern("yyyyMM");
            DateTimeFormatter yyyyMMdd = DateTimeFormatter.ofPattern("yyyyMMdd");
            for(int i = 0; i < 12; i++) {

                YearMonth targetMonth = YearMonth.now().minusMonths(i);
                LocalDate startDate = targetMonth.atDay(1);
                LocalDate endDate = targetMonth.atEndOfMonth();

                String key = targetMonth.format(yyyyMM);
                String startDateString = startDate.format(yyyyMM);
                String endDateString = endDate.format(yyyyMM);

                long monthlyTotal = 0;

                for (Card card : cardList) {
                    RequestFindBilling requestFindBilling = RequestFindBilling.builder()
                            .cvc(card.getCvc())
                            .cardNo(card.getCardNo())
                            .startMonth(startDateString)
                            .endMonth(endDateString)
                            .userKey(userKey)
                            .build();
                    Map<String, Object> cardBillApi = cardAPI.findBilling(requestFindBilling);
                    Map<String, Object> cardBillData = (Map<String, Object>) cardBillApi.get("apiResponse");
                    List<Map<String, Object>> recList = (List<Map<String, Object>>) cardBillData.get("REC");
                    if (!recList.isEmpty()) {
                        Map<String, Object> bill = recList.getFirst();
                        List<Map<String, Object>> billingList = (List<Map<String, Object>>) bill.get("billingList");

                        if (!billingList.isEmpty()) {
                            Map<String, Object> billing = billingList.getFirst();
                            long totalAmount = Long.parseLong((String) billing.get("totalBalance"));
                            monthlyTotal  += totalAmount;
                        }
                    }
                }
                startDateString = startDate.format(yyyyMMdd);
                endDateString = endDate.format(yyyyMMdd);

                for(DemandDeposit demandDeposit : demandDepositList){

                    RequestFindTransactionList requestFindTransactionlist = RequestFindTransactionList.builder()
                            .accountNo(demandDeposit.getAccountNo())
                            .startDate(startDateString)
                            .endDate(endDateString)
                            .transactionType("D")
                            .orderByType("DESC")
                            .userKey(userKey)
                            .build();
                    Map<String, Object> demandDepositApi = demandDepositAPI.findTransactionList(requestFindTransactionlist);
                    Map<String, Object> demandDepositData = (Map<String, Object>) demandDepositApi.get("apiResponse");

                    if (!demandDepositData.isEmpty()) {
                        Map<String, Object> recList = (Map<String, Object>) demandDepositData.get("REC");
                        if(!recList.isEmpty()){
                            List<Map<String, Object>> transactionList = (List<Map<String, Object>>) recList.get("list");

                            if (Objects.nonNull(transactionList)) {
                                for (Map<String, Object> tx : transactionList) {
                                    long spending = Long.parseLong((String) tx.get("transactionBalance"));
                                    monthlyTotal += spending;
                                }
                            }
                        }
                    }
                }
                monthlySpendingMap.put(key, monthlyTotal);
            }

            // 고정 지출 (적금)
            LocalDate today = LocalDate.now();

            for (Savings saving : savingsList) {
                LocalDate expiryDate = LocalDate.parse(saving.getAccountExpiryDate(), yyyyMMdd);

                if (today.isBefore(expiryDate)) {
                    int totalPeriod = Integer.parseInt(saving.getSubscriptionPeriod());
                    int paidMonths = Integer.parseInt(saving.getInstallmentNumber());
                    int remainingMonths = totalPeriod - paidMonths;
                    long monthlyAmount = Long.parseLong(saving.getDepositBalance());

                    YearMonth current = YearMonth.now();
                    for (int i = 0; i < remainingMonths; i++) {
                        YearMonth month = current.plusMonths(i);
                        String key = month.format(yyyyMM);
                        monthlySpendingMap.put(key, monthlySpendingMap.getOrDefault(key, 0L) + monthlyAmount);
                    }
                }
            }
            // 5. 최근 12개월만 필터링 (출력용)
            YearMonth now = YearMonth.now();
            List<String> recent12Keys = new ArrayList<>();
            for (int i = 11; i >= 0; i--) {
                YearMonth month = now.minusMonths(i);
                recent12Keys.add(month.format(yyyyMM));
            }

            Map<String, Long> filteredMap = new LinkedHashMap<>();
            for (String key : recent12Keys) {
                filteredMap.put(key, monthlySpendingMap.getOrDefault(key, 0L));
            }

            // 6. 평균 계산 (무조건 12개월로 나누기)
            long totalSpending = filteredMap.values().stream().mapToLong(Long::longValue).sum();
            long averageMonthlySpending = totalSpending / 12;

            return AverageSpendingResponseDto.builder()
                    .monthlySpendingMap(filteredMap)
                    .averageMonthlySpending(averageMonthlySpending)
                    .build();

        } catch (JsonProcessingException e) {
            throw new RuntimeException(e);
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("평균 지출 계산 중 오류 발생", e);
        }
    }
}
