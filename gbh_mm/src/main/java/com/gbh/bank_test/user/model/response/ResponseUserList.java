package com.gbh.bank_test.user.model.response;

import com.gbh.bank_test.user.model.entity.User;
import java.util.List;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class ResponseUserList {
    private int code;
    private String message;
    private List<User> userList;
}
