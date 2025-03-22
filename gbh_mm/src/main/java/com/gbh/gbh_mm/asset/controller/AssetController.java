package com.gbh.gbh_mm.asset.controller;

import com.gbh.gbh_mm.asset.model.vo.response.ResponseFindDepositDemandTransactionList;
import com.gbh.gbh_mm.asset.model.vo.response.ResponseFindDepositPayment;
import com.gbh.gbh_mm.asset.service.AssetService;
import com.gbh.gbh_mm.asset.model.vo.request.RequestFindAssetList;
import com.gbh.gbh_mm.asset.model.vo.response.ResponseFindAssetList;
import com.gbh.gbh_mm.finance.demandDeposit.vo.request.RequestFindTransactionList;
import com.gbh.gbh_mm.finance.deposit.vo.request.RequestFindPayment;
import lombok.AllArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

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
    public ResponseEntity<ResponseFindDepositPayment> findDepositTransactionList(
            @RequestBody RequestFindPayment request
    ) {
        ResponseFindDepositPayment response = assetService.findDepositPayment(request);

        return ResponseEntity.ok(response);
    }

    /* 적금 계좌 내역 조회 */

    /* 대출 계좌 내역 조회 */

    /* 카드 내역 조회 */
}
