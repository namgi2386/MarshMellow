package com.gbh.gbh_mm.household.controller;

import com.gbh.gbh_mm.household.model.vo.request.RequestCreateHousehold;
import com.gbh.gbh_mm.household.model.vo.request.RequestFindHousehold;
import com.gbh.gbh_mm.household.model.vo.request.RequestFindHouseholdList;
import com.gbh.gbh_mm.household.model.vo.response.ResponseCreateHousehold;
import com.gbh.gbh_mm.household.model.vo.response.ResponseFindHousehold;
import com.gbh.gbh_mm.household.model.vo.response.ResponseFindHouseholdList;
import com.gbh.gbh_mm.household.service.HouseholdService;
import lombok.AllArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
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
}
