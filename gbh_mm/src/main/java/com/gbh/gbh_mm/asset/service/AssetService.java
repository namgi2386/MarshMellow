package com.gbh.gbh_mm.asset.service;

import com.gbh.gbh_mm.asset.model.vo.request.RequestFindAssetList;
import com.gbh.gbh_mm.asset.model.vo.response.ResponseFindAssetList;

public interface AssetService {

    ResponseFindAssetList findAssetList(RequestFindAssetList request);
}
