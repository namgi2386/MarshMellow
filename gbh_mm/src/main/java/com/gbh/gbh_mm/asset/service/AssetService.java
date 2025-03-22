package com.gbh.gbh_mm.asset.service;

import com.gbh.gbh_mm.asset.model.vo.request.RequestFindAssetList;
import com.gbh.gbh_mm.asset.model.vo.response.ResponseFindAssetList;
import com.gbh.gbh_mm.asset.model.vo.response.ResponseFindDepositDemandTransactionList;
import com.gbh.gbh_mm.asset.model.vo.response.ResponseFindDepositPayment;
import com.gbh.gbh_mm.asset.model.vo.response.ResponseFindSavingsPaymentList;
import com.gbh.gbh_mm.finance.demandDeposit.vo.request.RequestFindTransactionList;
import com.gbh.gbh_mm.finance.deposit.vo.request.RequestFindPayment;
import com.gbh.gbh_mm.finance.savings.vo.request.RequestFindSavingsPayment;

public interface AssetService {

    ResponseFindAssetList findAssetList(RequestFindAssetList request);


    ResponseFindDepositDemandTransactionList findDepositDemandTransactionList(RequestFindTransactionList request);

    ResponseFindDepositPayment findDepositPayment(RequestFindPayment request);

    ResponseFindSavingsPaymentList findSavingsPaymentList(RequestFindSavingsPayment request);
}
