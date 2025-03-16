package com.gbh.bank_test.user.controller;

import com.gbh.bank_test.user.model.request.RequestCreateUser;
import com.gbh.bank_test.user.model.response.ResponseCreateUser;
import com.gbh.bank_test.user.model.response.ResponseUser;
import com.gbh.bank_test.user.model.response.ResponseUserList;
import com.gbh.bank_test.user.service.UserService;
import lombok.AllArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/user")
@AllArgsConstructor
public class UserController {
    private final UserService userService;

    @PostMapping
    public ResponseEntity<ResponseCreateUser> createUser(
        @RequestBody RequestCreateUser request
    ) {
        ResponseCreateUser response = userService.createUser(request);

        return ResponseEntity.ok(response);
    }

    @GetMapping
    public ResponseEntity<ResponseUserList> getUserList() {
        ResponseUserList response = userService.getUserList();

        return ResponseEntity.ok(response);
    }

    @GetMapping("/{userPk}")
    public ResponseEntity<ResponseUser> getUser(@PathVariable int userPk) {
        ResponseUser response = userService.getUser(userPk);

        return ResponseEntity.ok(response);
    }
}
