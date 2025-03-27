package com.gbh.gbh_mm.household.service;

import com.gbh.gbh_mm.household.model.vo.request.RequestCreateHousehold;
import com.gbh.gbh_mm.household.model.vo.request.RequestFindHousehold;
import com.gbh.gbh_mm.household.model.vo.request.RequestFindHouseholdList;
import com.gbh.gbh_mm.household.model.vo.request.RequestUpdateHousehold;
import com.gbh.gbh_mm.household.model.vo.response.ResponseCreateHousehold;
import com.gbh.gbh_mm.household.model.vo.response.ResponseFindHousehold;
import com.gbh.gbh_mm.household.model.vo.response.ResponseFindHouseholdList;
import com.gbh.gbh_mm.household.model.vo.response.ResponseUpdateHousehold;

public interface HouseholdService {

    ResponseFindHouseholdList findHouseholdList(RequestFindHouseholdList request);

    ResponseCreateHousehold createHousehold(RequestCreateHousehold request);

    ResponseFindHousehold findHousehold(RequestFindHousehold request);

    ResponseUpdateHousehold updateHousehold(RequestUpdateHousehold request);
}
