package com.gbh.gbh_mm.household.controller;

import com.gbh.gbh_mm.household.model.vo.request.RequestFindHouseholdList;
import com.gbh.gbh_mm.household.model.vo.response.ResponseFindHouseholdList;
import com.gbh.gbh_mm.household.service.HouseholdService;
import lombok.AllArgsConstructor;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/household")
@AllArgsConstructor
public class HouseholdController {
    private final HouseholdService householdService;

    public ResponseFindHouseholdList findHouseholdList(
        @RequestBody RequestFindHouseholdList request
    ) {
        ResponseFindHouseholdList response = householdService.findHouseholdList(request);

        return response;
    }
}
