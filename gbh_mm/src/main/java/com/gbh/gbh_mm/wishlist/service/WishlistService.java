package com.gbh.gbh_mm.wishlist.service;

import com.gbh.gbh_mm.user.model.entity.User;
import com.gbh.gbh_mm.user.repo.UserRepository;
import com.gbh.gbh_mm.wishlist.model.entity.Wishlist;
import com.gbh.gbh_mm.wishlist.model.response.ResponseFindWishlist;
import com.gbh.gbh_mm.wishlist.repo.WishlistRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class WishlistService {

    private final WishlistRepository wishlistRepository;
    private final UserRepository userRepository;

    // 위시리스트 생성
    @Transactional
    public void createWishlist(Long userPk, Wishlist wishlist) {
        User user = userRepository.findById(userPk)
                .orElseThrow(() -> new RuntimeException("User not found"));

        wishlist.setUser(user);
        wishlistRepository.save(wishlist);
    }

    // 위시리스트 조회
    public List<ResponseFindWishlist.WishlistData> getWishlist(Long userPk) {
        List<Wishlist> wishlist = wishlistRepository.findAllByUser_UserPk(userPk);
        List<ResponseFindWishlist.WishlistData> wishlistData = wishlist.stream()
                .map(wish -> ResponseFindWishlist.WishlistData.builder()
                        .wishlistPk(wish.getWishlistPk())
                        .productNickname(wish.getProductNickname())
                        .productName(wish.getProductName())
                        .productPrice(wish.getProductPrice())
                        .productImageUrl(wish.getProductImageUrl())
                        .productUrl(wish.getProductUrl())
                        .isSelected(wish.getIsSelected())
                        .isCompleted(wish.getIsCompleted())
                        .depositAccountCode(wish.getDepositAccountCode())
                        .build()
                )
                .collect(Collectors.toList());
        return wishlistData;



    }

    // 위시리스트 상세 조회
    public Wishlist getWishlistDetail(Long wishlistPk) {
        return wishlistRepository.findById(wishlistPk)
                .orElseThrow(() -> new RuntimeException("Wishlist not found"));
    }

    // 위시리스트 수정
    public Wishlist updateWishlist(Long wishlistPk, Wishlist wishlist) {
        Wishlist oldWishlist = wishlistRepository.findById(wishlistPk)
                .orElseThrow(() -> new RuntimeException("Wishlist not found"));

        oldWishlist.setProductNickname(wishlist.getProductNickname());
        oldWishlist.setProductName(wishlist.getProductName());
        oldWishlist.setProductPrice(wishlist.getProductPrice());
        oldWishlist.setProductImageUrl(wishlist.getProductImageUrl());
        oldWishlist.setProductUrl(wishlist.getProductUrl());
        oldWishlist.setIsSelected(wishlist.getIsSelected());
        oldWishlist.setIsCompleted(wishlist.getIsCompleted());
        oldWishlist.setDepositAccountCode(wishlist.getDepositAccountCode());
        return wishlistRepository.save(oldWishlist);



    }

    // 위시리스트 삭제
    @Transactional
    public void deleteWishlist(Long wishlistPk) {
        Wishlist wishlist = wishlistRepository.findById(wishlistPk)
                .orElseThrow(() -> new RuntimeException("Wishlist not found"));

        wishlistRepository.delete(wishlist);

    }
}
