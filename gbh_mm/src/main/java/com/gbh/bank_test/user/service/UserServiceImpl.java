package com.gbh.bank_test.user.service;

import com.gbh.bank_test.user.model.entity.User;
import com.gbh.bank_test.user.model.request.RequestCreateUser;
import com.gbh.bank_test.user.model.response.ResponseCreateUser;
import com.gbh.bank_test.user.model.response.ResponseUser;
import com.gbh.bank_test.user.model.response.ResponseUserList;
import com.gbh.bank_test.user.repo.UserRepository;
import jakarta.persistence.EntityNotFoundException;
import java.util.List;
import java.util.Optional;
import lombok.AllArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.stereotype.Service;

@Service
@AllArgsConstructor
public class UserServiceImpl implements UserService {
    private final UserRepository userRepository;
    private final ModelMapper mapper;

    @Override
    public ResponseCreateUser createUser(RequestCreateUser request) {
        User user = mapper.map(request, User.class);

        User savedUser = userRepository.save(user);

        if (savedUser.getUserPk() > 0) {
            ResponseCreateUser response = ResponseCreateUser.builder()
                .code(201)
                .message("정상적으로 등록됐습니다.")
                .user(savedUser)
                .build();

            return response;
        } else {
            ResponseCreateUser response = ResponseCreateUser.builder()
                .code(500)
                .message("등록 실패")
                .build();

            return response;
        }
    }

    @Override
    public ResponseUserList getUserList() {
        List<User> userList = userRepository.findAll();

        ResponseUserList response = ResponseUserList.builder()
            .code(200)
            .message("조회 성공")
            .userList(userList)
            .build();

        return response;
    }

    @Override
    public ResponseUser getUser(int userPk) {
        Optional<User> user = userRepository.findById(userPk);

        if (user.isPresent()) {
            ResponseUser response = ResponseUser.builder()
                .code(200)
                .message("조회 성공")
                .user(user.get())
                .build();
            return response;
        } else {
            ResponseUser response = ResponseUser.builder()
                .code(500)
                .message("조회 실패")
                .build();

            return response;
        }
    }
}
