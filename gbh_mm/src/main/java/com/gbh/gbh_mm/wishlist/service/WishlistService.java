package com.gbh.gbh_mm.wishlist.service;

import com.gbh.gbh_mm.common.exception.CustomException;
import com.gbh.gbh_mm.common.exception.ErrorCode;
import com.gbh.gbh_mm.user.model.entity.User;
import com.gbh.gbh_mm.user.repo.UserRepository;
import com.gbh.gbh_mm.wishlist.model.entity.Wishlist;
import com.gbh.gbh_mm.wishlist.model.request.RequestUpdateWishlist;
import com.gbh.gbh_mm.wishlist.model.response.*;
import com.gbh.gbh_mm.wishlist.repo.WishlistRepository;
import lombok.RequiredArgsConstructor;
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
    public ResponseCreateWishlist createWishlist(Long userPk, Wishlist wishlist) {
        User user = userRepository.findById(userPk)
                .orElseThrow(() -> new CustomException(ErrorCode.CHILD_NOT_FOUND));

        wishlist.setUser(user);
        wishlistRepository.save(wishlist);
        return ResponseCreateWishlist.builder()
                .message("위시리스트 생성 완료")
                .wishlistPk(wishlist.getWishlistPk())
                .productNickname(wishlist.getProductNickname())
                .productName(wishlist.getProductName())
                .productPrice(wishlist.getProductPrice())
                .productImageUrl(wishlist.getProductImageUrl())
                .productUrl(wishlist.getProductUrl())
                .isSelected(wishlist.getIsSelected())
                .isCompleted(wishlist.getIsCompleted())
                .build();
    }

    // 위시리스트 조회
    public ResponseFindWishlist getWishlist(Long userPk) {
        List<Wishlist> wishlist = wishlistRepository.findAllByUser_UserPk(userPk);
        List<ResponseFindWishlist.WishlistData> wishlistData = wishlist.stream()
                .map(wish -> ResponseFindWishlist.WishlistData.builder()
                        .wishlistPk(wish.getWishlistPk())
                        .productNickname(wish.getProductNickname())
                        .productName(wish.getProductName())
                        .productPrice(wish.getProductPrice())
                        .achievePrice(wish.getAchievePrice())
                        .productImageUrl(wish.getProductImageUrl())
                        .productUrl(wish.getProductUrl())
                        .isSelected(wish.getIsSelected())
                        .isCompleted(wish.getIsCompleted())
                        .build()
                )
                .collect(Collectors.toList());

        return ResponseFindWishlist.builder()
                .message("위시리스트 조회")
                .wishlist(wishlistData)
                .build();


    }

    // 위시리스트 상세 조회
    public ResponseFindDetailWishlist getWishlistDetail(Long wishlistPk) {

        Wishlist wishlist = wishlistRepository.findById(wishlistPk)
                .orElseThrow(() -> new CustomException(ErrorCode.RESOURCE_NOT_FOUND));

        return ResponseFindDetailWishlist.builder()
                .wishlistPk(wishlist.getWishlistPk())
                .productNickname(wishlist.getProductNickname())
                .productName(wishlist.getProductName())
                .productPrice(wishlist.getProductPrice())
                .achievePrice(wishlist.getAchievePrice())
                .productImageUrl(wishlist.getProductImageUrl())
                .productUrl(wishlist.getProductUrl())
                .isSelected(wishlist.getIsSelected())
                .isCompleted(wishlist.getIsCompleted())
                .build();
    }

    // 위시리스트 수정
    public ResponseUpdateWishlist updateWishlist(Long wishlistPk, RequestUpdateWishlist requestUpdateWishlist) {
        Wishlist oldWishlist = wishlistRepository.findById(wishlistPk)
                .orElseThrow(() -> new CustomException(ErrorCode.RESOURCE_NOT_FOUND));

        String oldProductNickname = oldWishlist.getProductNickname();
        String oldProductName = oldWishlist.getProductName();
        Long oldProductPrice = oldWishlist.getProductPrice();
        String oldProductImageUrl = oldWishlist.getProductImageUrl();
        String oldProductUrl = oldWishlist.getProductUrl();

        oldWishlist.setProductNickname(requestUpdateWishlist.getProductNickname());
        oldWishlist.setProductName(requestUpdateWishlist.getProductName());
        oldWishlist.setProductPrice(requestUpdateWishlist.getProductPrice());
        oldWishlist.setProductImageUrl(requestUpdateWishlist.getProductImageUrl());
        oldWishlist.setProductUrl(requestUpdateWishlist.getProductUrl());
        wishlistRepository.save(oldWishlist);

        return ResponseUpdateWishlist.builder()
                .message("위시리스트 수정 완료")
                .wishlistPk(wishlistPk)
                .oldNickname(oldProductNickname)
                .newNickname(requestUpdateWishlist.getProductNickname())
                .oldProductName(oldProductName)
                .newProductName(requestUpdateWishlist.getProductName())
                .oldProductPrice(oldProductPrice)
                .newProductPrice(requestUpdateWishlist.getProductPrice())
                .oldProductImageUrl(oldProductImageUrl)
                .newProductImageUrl(requestUpdateWishlist.getProductImageUrl())
                .oldProductUrl(oldProductUrl)
                .newProductUrl(requestUpdateWishlist.getProductUrl())
                .build();
    }

    // 위시리스트 삭제
    @Transactional
    public ResponseDeleteWishlist deleteWishlist(Long wishlistPk) {
        Wishlist wishlist = wishlistRepository.findById(wishlistPk)
                .orElseThrow(() -> new CustomException(ErrorCode.RESOURCE_NOT_FOUND));

        wishlistRepository.delete(wishlist);
        return ResponseDeleteWishlist.builder()
                .message("위시리스트 삭제 완료")
                .deleteWishlistPk(wishlistPk)
                .build();
    }

    // 현재 위시 조회
    public ResponseFindDetailWishlist getCurrentWish(Long userPk) {
        List<Wishlist> wishlist = wishlistRepository.findAllByUser_UserPk(userPk)
                .stream()
                .filter(wish ->
                        wish.getIsSelected().equals("Y") && wish.getIsCompleted().equals("N")
                )
                .collect(Collectors.toList());

        if (wishlist.isEmpty()) {
            throw new CustomException(ErrorCode.RESOURCE_NOT_FOUND);
        }

        if (wishlist.size() > 1) {
            throw new CustomException(ErrorCode.DATABASE_ERROR);
        }

        Wishlist wish = wishlist.get(0);
        return ResponseFindDetailWishlist.builder()
                .wishlistPk(wish.getWishlistPk())
                .productNickname(wish.getProductNickname())
                .productName(wish.getProductName())
                .productPrice(wish.getProductPrice())
                .achievePrice(wish.getAchievePrice())
                .productImageUrl(wish.getProductImageUrl())
                .productUrl(wish.getProductUrl())
                .isSelected(wish.getIsSelected())
                .isCompleted(wish.getIsCompleted())
                .build();
    }
}
