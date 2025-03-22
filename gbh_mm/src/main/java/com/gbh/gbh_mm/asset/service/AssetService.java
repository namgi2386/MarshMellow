package com.gbh.gbh_mm.asset.service;

import com.gbh.gbh_mm.asset.model.vo.request.RequestFindAssetList;
import com.gbh.gbh_mm.asset.model.vo.request.RequestFindDepositDemandTransactionList;
import com.gbh.gbh_mm.asset.model.vo.response.ResponseFindAssetList;
import com.gbh.gbh_mm.asset.model.vo.response.ResponseFindDepositDemandTransactionList;
import com.gbh.gbh_mm.finance.demandDeposit.vo.request.RequestFindTransactionList;

public interface AssetService {

    ResponseFindAssetList findAssetList(RequestFindAssetList request);


    ResponseFindDepositDemandTransactionList findDepositDemandTransactionList(RequestFindTransactionList request);
}
