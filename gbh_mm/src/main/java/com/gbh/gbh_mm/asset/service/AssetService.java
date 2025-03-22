package com.gbh.gbh_mm.asset.service;

import com.gbh.gbh_mm.asset.model.vo.request.RequestFindAssetList;
import com.gbh.gbh_mm.asset.model.vo.response.*;
import com.gbh.gbh_mm.finance.demandDeposit.vo.request.RequestFindTransactionList;
import com.gbh.gbh_mm.finance.deposit.vo.request.RequestFindPayment;
import com.gbh.gbh_mm.finance.loan.vo.request.RequestFindRepaymentList;
import com.gbh.gbh_mm.finance.savings.vo.request.RequestFindSavingsPayment;

public interface AssetService {

    ResponseFindAssetList findAssetList(RequestFindAssetList request);


    ResponseFindDepositDemandTransactionList findDepositDemandTransactionList(RequestFindTransactionList request);

    ResponseFindDepositPayment findDepositPayment(RequestFindPayment request);

    ResponseFindSavingsPaymentList findSavingsPaymentList(RequestFindSavingsPayment request);

    ResponseFindLoanPaymentList findLoanPaymentList(RequestFindRepaymentList request);
}
