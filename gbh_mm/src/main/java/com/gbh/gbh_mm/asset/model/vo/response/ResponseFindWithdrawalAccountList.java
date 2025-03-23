package com.gbh.gbh_mm.asset.model.vo.response;

import com.gbh.gbh_mm.asset.model.entity.WithdrawalAccount;
import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class ResponseFindWithdrawalAccountList {
    List<WithdrawalAccount> withdrawalAccountList;
}
