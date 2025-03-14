package com.gbh.bank_test.user.model.response;

import com.gbh.bank_test.user.model.entity.User;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class ResponseCreateUser {
    private int code;
    private String message;
    private User user;
}
