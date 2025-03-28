package com.gbh.gbh_mm.autoTransaction.service;

import com.gbh.gbh_mm.autoTransaction.model.vo.request.RequestCreateAutoTransaction;
import com.gbh.gbh_mm.autoTransaction.model.vo.response.ResponseCreateAutoTransaction;

public interface AutoTransactionService {

    ResponseCreateAutoTransaction createAutoTransaction(RequestCreateAutoTransaction request);
}
