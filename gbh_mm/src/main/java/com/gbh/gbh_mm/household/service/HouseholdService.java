package com.gbh.gbh_mm.household.service;

import com.gbh.gbh_mm.household.model.vo.request.*;
import com.gbh.gbh_mm.household.model.vo.response.*;

public interface HouseholdService {

    ResponseFindHouseholdList findHouseholdList(RequestFindHouseholdList request);

    ResponseCreateHousehold createHousehold(RequestCreateHousehold request);

    ResponseFindHousehold findHousehold(RequestFindHousehold request);

    ResponseUpdateHousehold updateHousehold(RequestUpdateHousehold request);

    ResponseDeleteHousehold deleteHousehold(RequestDeleteHousehold request);

    ResponseFindTransactionDataList findTransactionDataList(RequestFindTransactionDataList request);

    ResponseCreateHouseholdList createHouseholdList(RequestCreateHouseholdList request);

    ResponseSearchHousehold searchHousehold(RequestSearchHousehold request);

    ResponseFilterHousehold filterHousehold(RequestFilterHousehold request);

    ResponsePaymentMethodList findPaymentMethodList(RequestPaymentMethodList request);
}
