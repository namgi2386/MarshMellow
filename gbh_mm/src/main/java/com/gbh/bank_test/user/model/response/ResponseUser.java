package com.gbh.bank_test.user.model.response;


import com.gbh.bank_test.user.model.entity.User;
import lombok.Builder;
import lombok.Data;

@Builder
@Data
public class ResponseUser {
    private int code;
    private String message;
    private User user;
}
