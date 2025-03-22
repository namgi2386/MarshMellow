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
import com.gbh.gbh_mm.asset.model.entity.Card;
import com.gbh.gbh_mm.asset.model.entity.DemandDeposit;
import com.gbh.gbh_mm.asset.model.entity.Deposit;
import com.gbh.gbh_mm.asset.model.entity.Loan;
import com.gbh.gbh_mm.asset.model.entity.Savings;
import com.gbh.gbh_mm.asset.model.vo.request.RequestFindAssetList;
import com.gbh.gbh_mm.asset.model.vo.response.*;
import com.gbh.gbh_mm.finance.card.vo.request.RequestFindBilling;

import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import com.gbh.gbh_mm.finance.demandDeposit.vo.request.RequestFindTransactionList;
import com.gbh.gbh_mm.finance.deposit.vo.request.RequestFindPayment;
import com.gbh.gbh_mm.finance.loan.vo.request.RequestFindRepaymentList;
import com.gbh.gbh_mm.finance.savings.vo.request.RequestFindSavingsPayment;
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
            /* 목록 조회 API 호출 */
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

            List<Card> cardList = responseCardList.stream()
                .map(cardMap -> mapper.map(cardMap, Card.class))
                .collect(Collectors.toList());

            YearMonth current = YearMonth.now();
            YearMonth lastMonth = current.minusMonths(1);

            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMM");
            String currentString = current.format(formatter);
            String lastMonthString = lastMonth.format(formatter);

            long cardAmount = 0;
            for (int i = 0; i < cardList.size(); i++) {
                RequestFindBilling requestFindBilling = RequestFindBilling.builder()
                    .cvc(cardList.get(i).getCvc())
                    .cardNo(cardList.get(i).getCardNo())
                    .startMonth(lastMonthString)
                    .endMonth(currentString)
                    .userKey(request.getUserKey())
                    .build();
                Map<String, Object> cardBillApi = cardAPI.findBilling(requestFindBilling);
                Map<String, Object> cardBillData =
                    (Map<String, Object>) cardBillApi.get("apiResponse");
                List<Map<String, Object>> recList =
                    (List<Map<String, Object>>) cardBillData.get("REC");

                if (recList.size() > 0) {
                    Map<String, Object> bill = recList.get(0);
                    List<Map<String, Object>> billingList =
                        (List<Map<String, Object>>) bill.get("billingList");
                    Map<String, Object> billing = billingList.get(0);
                    long totalAmount = (long) billing.get("totalBalance");

                    cardAmount += totalAmount;
                    cardList.get(i).setCardBalance(totalAmount);
                }
            }

            CardListDto responseCard = CardListDto.builder()
                .totalAmount(cardAmount)
                .cardList(cardList)
                .build();

            /* 데이터 매핑(직렬화) */
            List<DemandDeposit> demandDepositList = responseDemandDepositList.stream()
                .map(demandDepositMap ->
                    mapper.map(demandDepositMap, DemandDeposit.class))
                .collect(Collectors.toList());

            /* 총 금액 계산 */
            long demandDepositTotal = demandDepositList.stream()
                .mapToLong(DemandDeposit::getAccountBalance)
                .sum();
            DemandDepositListDto responseDemandDeposit = DemandDepositListDto.builder()
                .demandDepositList(demandDepositList)
                .totalAmount(demandDepositTotal)
                .build();

            /* 데이터 매핑(직렬화) */
            List<Loan> loanList = responseLoanList.stream()
                .map(loanMap -> mapper.map(loanMap, Loan.class))
                .collect(Collectors.toList());

            /* 총 금액 계산 */
            long loanTotalAmount = loanList.stream()
                .mapToLong(Loan::getLoanBalance)
                .sum();
            LoanListDto responseLoan = LoanListDto.builder()
                .totalAmount(loanTotalAmount)
                .loanList(loanList)
                .build();

            /* 데이터 매핑(직렬화) */
            List<Savings> savingsList = savings.stream()
                .map(savingsMap -> mapper.map(savingsMap, Savings.class))
                .collect(Collectors.toList());

            /* 총 금액 계산 */
            long savingTotalAmount = savingsList.stream()
                .mapToLong(Savings::getTotalBalance)
                .sum();
            SavingsListDto responseSavings = SavingsListDto.builder()
                .totalAmount(savingTotalAmount)
                .savingsList(savingsList)
                .build();

            /* 데이터 직렬화 */
            List<Deposit> depositList = deposits.stream()
                .map(depositMap -> mapper.map(depositMap, Deposit.class))
                .collect(Collectors.toList());

            /* 총 금액 계산 */
            long depositTotalAmount = depositList.stream()
                .mapToLong(Deposit::getDepositBalance)
                .sum();
            DepositListDto responseDeposit = DepositListDto.builder()
                .totalAmount(depositTotalAmount)
                .depositList(depositList)
                .build();

            response.setCardData(responseCard);
            response.setDemandDepositData(responseDemandDeposit);
            response.setLoanData(responseLoan);
            response.setSavingsData(responseSavings);
            response.setDepositData(responseDeposit);
        } catch (JsonProcessingException e) {
            throw new RuntimeException(e);
        }
        return response;
    }

    @Override
    public ResponseFindDepositDemandTransactionList findDepositDemandTransactionList(RequestFindTransactionList request) {
        ResponseFindDepositDemandTransactionList response = new ResponseFindDepositDemandTransactionList();
        try {
            Map<String, Object> apiData = demandDepositAPI.findTransactionList(request);
            Map<String, Object> responseData = (Map<String, Object>) apiData.get("apiResponse");
            Map<String, Object> transactionData = (Map<String, Object>) responseData.get("REC");
            List<Map<String, Object>> transactionList = (List<Map<String, Object>>) transactionData.get("list");
            response.setTransactionList(transactionList);

        } catch (JsonProcessingException e) {
            throw new RuntimeException(e);
        }
        return response;
    }

    @Override
    public ResponseFindDepositPayment findDepositPayment(RequestFindPayment request) {
        ResponseFindDepositPayment response = new ResponseFindDepositPayment();

        try {
            Map<String, Object> apiData = depositAPI.findPayment(request);
            Map<String, Object> responseData = (Map<String, Object>) apiData.get("apiResponse");
            Map<String, Object> paymentData = (Map<String, Object>) responseData.get("REC");

            response.setPayment(paymentData);
        } catch (JsonProcessingException e) {
            throw new RuntimeException(e);
        }

        return response;
    }

    @Override
    public ResponseFindSavingsPaymentList findSavingsPaymentList(RequestFindSavingsPayment request) {
        ResponseFindSavingsPaymentList response = new ResponseFindSavingsPaymentList();

        try {
            Map<String, Object> apiData = savingsAPI.findPayment(request);
            Map<String, Object> responseData = (Map<String, Object>) apiData.get("apiResponse");
            List<Map<String, Object>> paymentList = (List<Map<String, Object>>) responseData.get("REC");
            response.setPaymentList(paymentList);


        } catch (JsonProcessingException e) {
            throw new RuntimeException(e);
        }

        return response;
    }

    @Override
    public ResponseFindLoanPaymentList findLoanPaymentList(RequestFindRepaymentList request) {
        mapper.getConfiguration().setMatchingStrategy(MatchingStrategies.STRICT);

        try {
            Map<String, Object> apiData = loanAPI.findRepaymentList(request);
            Map<String, Object> responseData = (Map<String, Object>) apiData.get("apiResponse");
            Map<String, Object> recData = (Map<String, Object>) responseData.get("REC");
            ResponseFindLoanPaymentList response = mapper.map(recData, ResponseFindLoanPaymentList.class);

            return response;
        } catch (JsonProcessingException e) {
            throw new RuntimeException(e);
        }
    }
}
