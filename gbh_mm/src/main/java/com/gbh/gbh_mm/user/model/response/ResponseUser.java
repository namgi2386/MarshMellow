package com.gbh.gbh_mm.user.model.response;


import com.gbh.gbh_mm.user.model.entity.User;
import lombok.Builder;
import lombok.Data;

@Builder
@Data
public class ResponseUser {
    private int code;
    private String message;
    private User user;
}
