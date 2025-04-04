package com.gbh.gbh_mm.resign.service;

import com.gbh.gbh_mm.asset.service.AssetService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Service
@Slf4j
@RequiredArgsConstructor
public class ResignService {

    private final AssetService assetService;
}
