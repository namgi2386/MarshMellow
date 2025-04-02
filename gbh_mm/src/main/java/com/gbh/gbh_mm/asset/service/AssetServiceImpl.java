package com.gbh.gbh_mm.asset.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.gbh.gbh_mm.api.*;
import com.gbh.gbh_mm.asset.model.dto.CardListDto;
import com.gbh.gbh_mm.asset.model.dto.DemandDepositListDto;
import com.gbh.gbh_mm.asset.model.dto.DepositListDto;
import com.gbh.gbh_mm.asset.model.dto.LoanListDto;
import com.gbh.gbh_mm.asset.model.dto.SavingsListDto;
import com.gbh.gbh_mm.asset.model.dto.WithdrawalAccountDto;
import com.gbh.gbh_mm.asset.model.entity.*;
import com.gbh.gbh_mm.asset.model.vo.request.RequestCheckAccountAuth;
import com.gbh.gbh_mm.asset.model.vo.request.RequestFindCardTransactionList;
import com.gbh.gbh_mm.asset.model.vo.request.RequestFindDepositDemandTransactionList;
import com.gbh.gbh_mm.asset.model.vo.request.RequestFindDepositPayment;
import com.gbh.gbh_mm.asset.model.vo.request.RequestFindLoanPaymentList;
import com.gbh.gbh_mm.asset.model.vo.request.RequestFindSavingsPaymentList;
import com.gbh.gbh_mm.asset.model.vo.request.RequestOpenAccountAuth;
import com.gbh.gbh_mm.asset.model.vo.request.RequestWithdrawalAccountTransfer;
import com.gbh.gbh_mm.asset.model.vo.request.RequestDeleteWithdrawalAccount;
import com.gbh.gbh_mm.asset.model.vo.response.*;
import com.gbh.gbh_mm.asset.repo.WithdrawalAccountRepository;
import com.gbh.gbh_mm.finance.auth.vo.request.RequestCreateAccountAuth;
import com.gbh.gbh_mm.finance.card.vo.request.RequestFindBilling;

import com.gbh.gbh_mm.finance.demandDeposit.vo.request.RequestAccountTransfer;
import com.gbh.gbh_mm.user.model.entity.CustomUserDetails;
import java.lang.reflect.Type;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

import com.gbh.gbh_mm.finance.demandDeposit.vo.request.RequestFindTransactionList;
import com.gbh.gbh_mm.finance.deposit.vo.request.RequestFindPayment;
import com.gbh.gbh_mm.finance.loan.vo.request.RequestFindRepaymentList;
import com.gbh.gbh_mm.finance.savings.vo.request.RequestFindSavingsPayment;
import com.gbh.gbh_mm.user.model.entity.User;
import com.gbh.gbh_mm.user.repo.UserRepository;
import jakarta.persistence.EntityNotFoundException;
import lombok.AllArgsConstructor;
import org.modelmapper.ModelMapper;
import org.modelmapper.TypeToken;
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
    private final AuthAPI authAPI;

    private final ModelMapper mapper;

    private final UserRepository userRepository;
    private final WithdrawalAccountRepository withdrawalAccountRepository;

    @Override
    public ResponseFindAssetList findAssetList(CustomUserDetails customUserDetails) {
        mapper.getConfiguration().setMatchingStrategy(MatchingStrategies.STRICT);

        ResponseFindAssetList response = new ResponseFindAssetList();

        String userKey = customUserDetails.getUserKey();

        try {
            /* 목록 조회 API 호출 */
            Map<String, Object> responseCardData =
                    cardAPI.findUserCardList(userKey);
            Map<String, Object> responseDepositDemandData =
                    demandDepositAPI.findDemandDepositAccountList(userKey);
            Map<String, Object> responseLoanData =
                    loanAPI.findAccountList(userKey);
            Map<String, Object> responseSavingsData =
                    savingsAPI.findAccountList(userKey);
            Map<String, Object> responseDepositData =
                    depositAPI.findAccountList(userKey);

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
                        .userKey(userKey)
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
                    long totalAmount = Long.parseLong((String) billing.get("totalBalance"));

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
    public ResponseFindDepositDemandTransactionList findDepositDemandTransactionList(
        RequestFindDepositDemandTransactionList request,
        CustomUserDetails customUserDetails
    ) {
        ResponseFindDepositDemandTransactionList response =
            new ResponseFindDepositDemandTransactionList();
        try {
            RequestFindTransactionList requestApi = RequestFindTransactionList.builder()
                .accountNo(request.getAccountNo())
                .startDate(request.getStartDate())
                .endDate(request.getEndDate())
                .transactionType(request.getTransactionType())
                .orderByType(request.getOrderByType())
                .userKey(customUserDetails.getUserKey())
                .build();

            Map<String, Object> apiData = demandDepositAPI.findTransactionList(requestApi);
            Map<String, Object> responseData = (Map<String, Object>) apiData.get("apiResponse");
            Map<String, Object> transactionData = (Map<String, Object>) responseData.get("REC");
            List<Map<String, Object>> transactionList =
                (List<Map<String, Object>>) transactionData.get("list");
            response.setTransactionList(transactionList);

        } catch (JsonProcessingException e) {
            throw new RuntimeException(e);
        }
        return response;
    }

    @Override
    public ResponseFindDepositPayment findDepositPayment(
        RequestFindDepositPayment request,
        CustomUserDetails customUserDetails
    ) {
        ResponseFindDepositPayment response = new ResponseFindDepositPayment();

        try {
            RequestFindPayment requestApi = RequestFindPayment.builder()
                .accountNo(request.getAccountNo())
                .userKey(customUserDetails.getUserKey())
                .build();
            Map<String, Object> apiData = depositAPI.findPayment(requestApi);
            Map<String, Object> responseData = (Map<String, Object>) apiData.get("apiResponse");
            Map<String, Object> paymentData = (Map<String, Object>) responseData.get("REC");

            response.setPayment(paymentData);
        } catch (JsonProcessingException e) {
            throw new RuntimeException(e);
        }

        return response;
    }

    @Override
    public ResponseFindSavingsPaymentList findSavingsPaymentList(
        RequestFindSavingsPaymentList request,
        CustomUserDetails customUserDetails
    ) {
        ResponseFindSavingsPaymentList response = new ResponseFindSavingsPaymentList();

        try {
            RequestFindSavingsPayment requestApi = RequestFindSavingsPayment.builder()
                .accountNo(request.getAccountNo())
                .userKey(customUserDetails.getUserKey())
                .build();
            Map<String, Object> apiData = savingsAPI.findPayment(requestApi);
            Map<String, Object> responseData = (Map<String, Object>) apiData.get("apiResponse");
            List<Map<String, Object>> paymentList = (List<Map<String, Object>>) responseData.get("REC");
            response.setPaymentList(paymentList);


        } catch (JsonProcessingException e) {
            throw new RuntimeException(e);
        }

        return response;
    }

    @Override
    public ResponseFindLoanPaymentList findLoanPaymentList(
        RequestFindLoanPaymentList request,
        CustomUserDetails customUserDetails
    ) {
        mapper.getConfiguration().setMatchingStrategy(MatchingStrategies.STRICT);

        try {
            RequestFindRepaymentList requestApi = RequestFindRepaymentList.builder()
                .accountNo(request.getAccountNo())
                .userKey(customUserDetails.getUserKey())
                .build();
            Map<String, Object> apiData = loanAPI.findRepaymentList(requestApi);
            Map<String, Object> responseData = (Map<String, Object>) apiData.get("apiResponse");
            Map<String, Object> recData = (Map<String, Object>) responseData.get("REC");
            ResponseFindLoanPaymentList response = mapper.map(recData, ResponseFindLoanPaymentList.class);

            return response;
        } catch (JsonProcessingException e) {
            throw new RuntimeException(e);
        }
    }

    @Override
    public ResponseFindCardTransactionList findCardTransactionList(
        RequestFindCardTransactionList request,
        CustomUserDetails customUserDetails
    ) {
        mapper.getConfiguration().setMatchingStrategy(MatchingStrategies.STRICT);
        try {
            com.gbh.gbh_mm.finance.card.vo.request.RequestFindCardTransactionList requestApi =
                com.gbh.gbh_mm.finance.card.vo.request.RequestFindCardTransactionList.builder()
                    .cardNo(request.getCardNo())
                    .cvc(request.getCvc())
                    .startDate(request.getStartDate())
                    .endDate(request.getEndDate())
                    .userKey(customUserDetails.getUserKey())
                    .build();

            Map<String, Object> apiData = cardAPI.findTransactionList(requestApi);
            Map<String, Object> responseData = (Map<String, Object>) apiData.get("apiResponse");
            Map<String, Object> recData = (Map<String, Object>) responseData.get("REC");

            ResponseFindCardTransactionList response = mapper.map(recData, ResponseFindCardTransactionList.class);

            return response;
        } catch (JsonProcessingException e) {
            throw new RuntimeException(e);
        }
    }

    @Override
    public ResponseOpenAccountAuth openAccountAuth(
        RequestOpenAccountAuth request,
        CustomUserDetails customUserDetails) {
        try {
            RequestCreateAccountAuth requestApi = RequestCreateAccountAuth.builder()
                .accountNo(request.getAccountNo())
                .userKey(customUserDetails.getUserKey())
                .build();
            authAPI.createAccountAuth(requestApi);
        } catch (JsonProcessingException e) {
            throw new RuntimeException(e);
        }

        try {
            LocalDate currentDate = LocalDate.now();

            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMdd");
            String currentString = currentDate.format(formatter);

            RequestFindTransactionList requestTransaction = new RequestFindTransactionList();
            requestTransaction.setAccountNo(request.getAccountNo());
            requestTransaction.setUserKey(customUserDetails.getUserKey());
            requestTransaction.setOrderByType("DESC");
            requestTransaction.setTransactionType("M");
            requestTransaction.setEndDate(currentString);
            requestTransaction.setStartDate(currentString);

            Map<String, Object> apiData = demandDepositAPI.findTransactionList(requestTransaction);
            Map<String, Object> responseData = (Map<String, Object>) apiData.get("apiResponse");
            Map<String, Object> recData = (Map<String, Object>) responseData.get("REC");
            List<Map<String, Object>> transacionList = (List<Map<String, Object>>) recData.get("list");
            Map<String, Object> transactionData = transacionList.get(0);
            String transactionSummary = (String) transactionData.get("transactionSummary");
            String[] authCodeSplit = transactionSummary.split(" ");

            ResponseOpenAccountAuth response = new ResponseOpenAccountAuth();
            response.setAuthCode(authCodeSplit[1]);

            return response;
        } catch (JsonProcessingException e) {
            throw new RuntimeException(e);
        }
    }

    @Override
    public ResponseCheckAccountAuth checkAccountAuth(
        RequestCheckAccountAuth request,
        CustomUserDetails customUserDetails) {
        try {
            com.gbh.gbh_mm.finance.auth.vo.request.RequestCheckAccountAuth requestApi =
                com.gbh.gbh_mm.finance.auth.vo.request.RequestCheckAccountAuth.builder()
                    .accountNo(request.getAccountNo())
                    .authCode(request.getAuthCode())
                    .userKey(customUserDetails.getUserKey())
                    .build();

            Map<String, Object> apiData = authAPI.checkAccountAuth(requestApi);
            Map<String, Object> responseData = (Map<String, Object>) apiData.get("apiResponse");
            Map<String, Object> recData = (Map<String, Object>) responseData.get("REC");
            String checkStatus = (String) recData.get("status");
            if (checkStatus.equals("SUCCESS")) {
                User user = userRepository.findByUserKey(customUserDetails.getUserKey());

                if (user.getUserKey() != null) {
                    WithdrawalAccount withdrawalAccount = WithdrawalAccount.builder()
                            .accountNo(request.getAccountNo())
                            .user(user)
                            .build();

                    WithdrawalAccount savedWithdrawalAccount = withdrawalAccountRepository.save(withdrawalAccount);

                    ResponseCheckAccountAuth response = ResponseCheckAccountAuth.builder()
                            .status("SUCCESS")
                            .withdrawalAccountId(savedWithdrawalAccount.getWithdrawalAccountId())
                            .build();

                    return response;
                } else {
                    ResponseCheckAccountAuth response = ResponseCheckAccountAuth.builder()
                            .status("FAIL")
                            .build();

                    return response;
                }
            } else {
                return null;
            }
        } catch (JsonProcessingException e) {
            throw new RuntimeException(e);
        }
    }

    @Override
    public ResponseFindWithdrawalAccountList findWithdrawalAccountList
        (CustomUserDetails customUserDetails) {
        List<WithdrawalAccount> withdrawalAccountList = withdrawalAccountRepository
            .findByUser_UserPk(customUserDetails.getUserPk());
        Type listType = new TypeToken<List<WithdrawalAccountDto>>() {}.getType();
        List<WithdrawalAccountDto> withdrawalAccountDtos = mapper.map(withdrawalAccountList, listType);

        ResponseFindWithdrawalAccountList response = ResponseFindWithdrawalAccountList.builder()
                .withdrawalAccountList(withdrawalAccountDtos)
                .build();

        return response;
    }

    @Override
    public ResponseDeleteWithdrawalAccount deleteWithdrawalAccount(RequestDeleteWithdrawalAccount request) {

        try {
            Optional<WithdrawalAccount> withdrawalAccount =
                    withdrawalAccountRepository.findById(request.getWithdrawalAccountId());
            if (withdrawalAccount.isPresent()) {
                withdrawalAccountRepository.delete(withdrawalAccount.get());

                ResponseDeleteWithdrawalAccount response = ResponseDeleteWithdrawalAccount.builder()
                        .message("삭제 성공")
                        .build();

                return response;
            }

        } catch (Exception e) {
            new EntityNotFoundException("존재하지 않는 출금계좌");
        }
        return null;
    }

    @Override
    public ResponseAccountTransfer accountTransger(RequestWithdrawalAccountTransfer request) {
        try {
            WithdrawalAccount withdrawalAccount = withdrawalAccountRepository
                .findById(request.getWithdrawalAccountId())
                .orElseThrow(() -> new EntityNotFoundException("존재하지 않는 출금계죄"));

            String userKey = withdrawalAccount.getUser().getUserKey();

            RequestAccountTransfer apiRequest = new RequestAccountTransfer();
            apiRequest.setUserKey(userKey);
            apiRequest.setDepositAccountNo(request.getDepositAccountNo());
            apiRequest.setDepositTransactionSummary
                ("MarshMellow 입금 " + withdrawalAccount.getUser().getUserName());
            apiRequest.setWithdrawalAccountNo(withdrawalAccount.getAccountNo());
            apiRequest.setWithdrawalTransactionSummary(request.getTransactionSummary());
            apiRequest.setTransactionBalance(request.getTransactionBalance());

            demandDepositAPI.accountTransfer(apiRequest);

            ResponseAccountTransfer response = ResponseAccountTransfer.builder()
                    .message("이체 성공")
                    .build();

            return response;
        } catch (JsonProcessingException e) {
            throw new RuntimeException(e);
        }
    }
}
