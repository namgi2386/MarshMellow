package com.gbh.gbh_mm.autoTransaction.service;

import com.gbh.gbh_mm.autoTransaction.model.entity.AutoTransaction;
import com.gbh.gbh_mm.autoTransaction.model.vo.request.RequestCreateAutoTransaction;
import com.gbh.gbh_mm.autoTransaction.model.vo.response.ResponseCreateAutoTransaction;
import com.gbh.gbh_mm.autoTransaction.repo.AutoTransactionRepository;
import com.gbh.gbh_mm.user.model.entity.User;
import com.gbh.gbh_mm.user.repo.UserRepository;
import com.gbh.gbh_mm.wishlist.model.entity.Wishlist;
import com.gbh.gbh_mm.wishlist.repo.WishlistRepository;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@AllArgsConstructor
public class AutoTransactionServiceImpl implements AutoTransactionService {
    private final AutoTransactionRepository autoTransactionRepository;
    private final UserRepository userRepository;
    private final WishlistRepository wishlistRepository;

    @Override
    public ResponseCreateAutoTransaction createAutoTransaction(
        RequestCreateAutoTransaction request) {
        User user;
        Wishlist wishlist;
        try {
            user = userRepository.findById(request.getUserPk())
                .orElseThrow(() -> new Exception());
        } catch (Exception e) {
            ResponseCreateAutoTransaction response = ResponseCreateAutoTransaction.builder()
                .message("존재하지 않는 회원입니다.")
                .build();
            return response;
        }

        try {
            wishlist = wishlistRepository.findById(request.getWishListPk())
                .orElseThrow(() -> new Exception());
        } catch (Exception e) {
            ResponseCreateAutoTransaction response = ResponseCreateAutoTransaction.builder()
                .message("존재하지 않는 위시리스트입니다.")
                .build();
            return response;
        }


        AutoTransaction autoTransaction = AutoTransaction.builder()
            .withdrawalAccountNo(request.getWithdrawalAccountNo())
            .depositAccountNo(request.getDepositAccountNo())
            .dueDate(request.getDueDate())
            .transactionBalance(request.getTransactionBalance())
            .user(user)
            .wishlist(wishlist)
            .build();

        autoTransactionRepository.save(autoTransaction);

        ResponseCreateAutoTransaction response = ResponseCreateAutoTransaction.builder()
            .message("등록 성공")
            .build();
        return response;
    }
}
