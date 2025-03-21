package com.gbh.gbh_mm.asset.controller;

import com.gbh.gbh_mm.asset.service.AssetService;
import com.gbh.gbh_mm.asset.model.vo.request.RequestFindAssetList;
import com.gbh.gbh_mm.asset.model.vo.response.ResponseFindAssetList;
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

    @GetMapping
    public ResponseEntity<ResponseFindAssetList> findAssetList(
        @RequestBody RequestFindAssetList request
    ) {
        ResponseFindAssetList response = assetService.findAssetList(request);

        return ResponseEntity.ok(response);
    }
}
