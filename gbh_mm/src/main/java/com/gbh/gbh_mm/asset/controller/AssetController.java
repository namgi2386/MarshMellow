package com.gbh.gbh_mm.asset.controller;

import com.gbh.gbh_mm.asset.model.vo.request.RequestWithdrawalAccountTransfer;
import com.gbh.gbh_mm.asset.model.vo.request.RequestDeleteWithdrawalAccount;
import com.gbh.gbh_mm.asset.model.vo.request.RequestFindWithdrawalAccountList;
import com.gbh.gbh_mm.asset.model.vo.response.*;
import com.gbh.gbh_mm.asset.service.AssetService;
import com.gbh.gbh_mm.asset.model.vo.request.RequestFindAssetList;
import com.gbh.gbh_mm.finance.auth.vo.request.RequestCheckAccountAuth;
import com.gbh.gbh_mm.finance.auth.vo.request.RequestCreateAccountAuth;
import com.gbh.gbh_mm.finance.card.vo.request.RequestFindCardTransactionList;
import com.gbh.gbh_mm.finance.demandDeposit.vo.request.RequestFindTransactionList;
import com.gbh.gbh_mm.finance.deposit.vo.request.RequestFindPayment;
import com.gbh.gbh_mm.finance.loan.vo.request.RequestFindRepaymentList;
import com.gbh.gbh_mm.finance.savings.vo.request.RequestFindSavingsPayment;
import lombok.AllArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/asset")
@AllArgsConstructor
public class AssetController {
    private final AssetService assetService;

    /* 자산 목록 조회 */
    @GetMapping
    public ResponseEntity<ResponseFindAssetList> findAssetList(
            @RequestBody RequestFindAssetList request
    ) {
        ResponseFindAssetList response = assetService.findAssetList(request);

        return ResponseEntity.ok(response);
    }

    /* 입출금 계좌 내역 조회 */
    @GetMapping("/deposit-demand-transaction")
    public ResponseEntity<ResponseFindDepositDemandTransactionList> findDepositDemandTransactionList(
            @RequestBody RequestFindTransactionList request
    ) {
        ResponseFindDepositDemandTransactionList response = assetService.findDepositDemandTransactionList(request);

        return ResponseEntity.ok(response);
    }

    /* 예금 납입 내역 조회 */
    @GetMapping("/deposit-payment")
    public ResponseEntity<ResponseFindDepositPayment> findDepositPayment(
            @RequestBody RequestFindPayment request
    ) {
        ResponseFindDepositPayment response = assetService.findDepositPayment(request);

        return ResponseEntity.ok(response);
    }

    /* 적금 계좌 내역 조회 */
    @GetMapping("/savings-payment")
    public ResponseEntity<ResponseFindSavingsPaymentList> findSavingsPaymentList(
            @RequestBody RequestFindSavingsPayment request
    ) {
        ResponseFindSavingsPaymentList response = assetService.findSavingsPaymentList(request);

        return ResponseEntity.ok(response);
    }

    /* 대출 상환 내역 조회 */
    @GetMapping("/loan-payment")
    public ResponseEntity<ResponseFindLoanPaymentList> findLoanPaymentList(
            @RequestBody RequestFindRepaymentList request
    ) {
        ResponseFindLoanPaymentList response = assetService.findLoanPaymentList(request);

        return ResponseEntity.ok(response);
    }

    /* 카드 내역 조회 */
    @GetMapping("/card-transaction")
    public ResponseEntity<ResponseFindCardTransactionList> findCardTransactionList(
            @RequestBody RequestFindCardTransactionList request
    ) {
        ResponseFindCardTransactionList response = assetService.findCardTransactionList(request);

        return ResponseEntity.ok(response);
    }

    /* 1원 송금 */
    @PostMapping("/open-account-auth")
    public ResponseEntity<ResponseOpenAccountAuth> openAccountAuth(
            @RequestBody RequestCreateAccountAuth request
    ) {
        ResponseOpenAccountAuth response = assetService.openAccountAuth(request);

        return ResponseEntity.ok(response);
    }

    /* 1원 송금 인증 */
    @PostMapping("/check-account-auth")
    public ResponseEntity<ResponseCheckAccountAuth> checkAccountAuth(
            @RequestBody RequestCheckAccountAuth request
    ) {
        ResponseCheckAccountAuth response = assetService.checkAccountAuth(request);

        return ResponseEntity.ok(response);
    }

    /* 출금 계좌 목록 */
    @GetMapping("/withdrawal-account")
    public ResponseEntity<ResponseFindWithdrawalAccountList> findWithdrawalAccountList(
            @RequestBody RequestFindWithdrawalAccountList request
    ) {
        ResponseFindWithdrawalAccountList response = assetService.findWithdrawalAccountList(request);

        return ResponseEntity.ok(response);
    }

    /* 출금 계좌 삭제 */
    @DeleteMapping("/withdrawal-account")
    public ResponseEntity<ResponseDeleteWithdrawalAccount> deleteWithdrawalAccount(
            @RequestBody RequestDeleteWithdrawalAccount request
    ) {
        ResponseDeleteWithdrawalAccount response = assetService.deleteWithdrawalAccount(request);

        return ResponseEntity.ok(response);
    }

    /* 계좌 송금 */
    @PostMapping("/account-transfer")
    public ResponseEntity<ResponseAccountTransfer> accountTransfer(
            @RequestBody RequestWithdrawalAccountTransfer request
    ) {
        ResponseAccountTransfer response = assetService.accountTransger(request);

        return ResponseEntity.ok(response);
    }

}
