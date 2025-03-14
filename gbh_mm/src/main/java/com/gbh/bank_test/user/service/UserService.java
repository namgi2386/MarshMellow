package com.gbh.bank_test.user.service;

import com.gbh.bank_test.user.model.request.RequestCreateUser;
import com.gbh.bank_test.user.model.response.ResponseCreateUser;
import com.gbh.bank_test.user.model.response.ResponseUser;
import com.gbh.bank_test.user.model.response.ResponseUserList;

public interface UserService {

    ResponseCreateUser createUser(RequestCreateUser request);

    ResponseUserList getUserList();

    ResponseUser getUser(int userPk);
}
