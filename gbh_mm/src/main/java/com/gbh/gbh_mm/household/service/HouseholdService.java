package com.gbh.gbh_mm.household.service;

import com.gbh.gbh_mm.household.model.vo.request.RequestCreateHousehold;
import com.gbh.gbh_mm.household.model.vo.request.RequestFindHouseholdList;
import com.gbh.gbh_mm.household.model.vo.response.ResponseCreateHousehold;
import com.gbh.gbh_mm.household.model.vo.response.ResponseFindHouseholdList;

public interface HouseholdService {

    ResponseFindHouseholdList findHouseholdList(RequestFindHouseholdList request);

    ResponseCreateHousehold createHousehold(RequestCreateHousehold request);
}
