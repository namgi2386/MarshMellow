package com.gbh.gbh_mm.household.controller;

import com.gbh.gbh_mm.household.model.vo.request.*;
import com.gbh.gbh_mm.household.model.vo.response.*;
import com.gbh.gbh_mm.household.service.HouseholdService;
import lombok.AllArgsConstructor;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/household")
@AllArgsConstructor
public class HouseholdController {
    private final HouseholdService householdService;

    @GetMapping("/list")
    public ResponseFindHouseholdList findHouseholdList(
        @RequestBody RequestFindHouseholdList request
    ) {
        ResponseFindHouseholdList response = householdService.findHouseholdList(request);

        return response;
    }

    @PostMapping
    public ResponseCreateHousehold createHousehold(
        @RequestBody RequestCreateHousehold request
    ) {
        ResponseCreateHousehold response = householdService.createHousehold(request);

        return response;
    }

    @GetMapping
    public ResponseFindHousehold findHousehold(
        @RequestBody RequestFindHousehold request
    ) {
        ResponseFindHousehold response = householdService.findHousehold(request);

        return response;
    }

    @PatchMapping
    public ResponseUpdateHousehold updateHousehold(
        @RequestBody RequestUpdateHousehold request
    ) {
        ResponseUpdateHousehold response = householdService.updateHousehold(request);

        return response;
    }

    @DeleteMapping
    public ResponseDeleteHousehold deleteHousehold(
        @RequestBody RequestDeleteHousehold request
    ) {
        ResponseDeleteHousehold response = householdService.deleteHousehold(request);

        return response;
    }

    @GetMapping("/transaction-data")
    public ResponseFindTransactionDataList findTransactionDataList(
        @RequestBody RequestFindTransactionDataList request
    ) {
        ResponseFindTransactionDataList response = householdService.findTransactionDataList(request);

        return response;
    }

    @PostMapping("/household-list")
    public ResponseCreateHouseholdList createHouseholdList(
        @RequestBody RequestCreateHouseholdList request
    ) {
        ResponseCreateHouseholdList response = householdService.createHouseholdList(request);

        return response;
    }

    @GetMapping("/search")
    public ResponseSearchHousehold searchHousehold(
            @RequestBody RequestSearchHousehold request
    ) {
        ResponseSearchHousehold response = householdService.searchHousehold(request);

        return response;
    }

    @GetMapping("/filter")
    public ResponseFilterHousehold filterHousehold(
        @RequestBody RequestFilterHousehold request
    ) {
        ResponseFilterHousehold response = householdService.filterHousehold(request);

        return response;
    }


    @GetMapping("/payment-method")
    public ResponsePaymentMethodList findPaymentMethodList(
        @RequestBody RequestPaymentMethodList request
    ) {
        return householdService.findPaymentMethodList(request);
    }
}
