package com.gbh.gbh_mm.wishlist.controller;

import com.gbh.gbh_mm.wishlist.model.entity.Wishlist;
import com.gbh.gbh_mm.wishlist.model.response.ResponseCreateWishlist;
import com.gbh.gbh_mm.wishlist.model.response.ResponseFindDetailWishlist;
import com.gbh.gbh_mm.wishlist.model.response.ResponseFindWishlist;
import com.gbh.gbh_mm.wishlist.service.WishlistService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("api/mm/wishlist")
public class WishlistController {

    @Autowired
    private WishlistService wishlistService;

    // 위시리스트 생성
    @PostMapping("/{userPk}")
    public ResponseEntity<ResponseCreateWishlist> createWishlist(@PathVariable Long userPk, @RequestBody Wishlist wishList) {

        wishlistService.createWishlist(userPk, wishList);

        ResponseCreateWishlist response = ResponseCreateWishlist.builder()
                .code(200)
                .message("위시리스트 생성 완료")
                .build();

        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    // 위시리스트 조회
    @GetMapping("/{userPk}")
    public ResponseEntity<ResponseFindWishlist> getWishlist(@PathVariable Long userPk) {
        List<ResponseFindWishlist.WishlistData> wishlistData = wishlistService.getWishlist(userPk);

        ResponseFindWishlist response = ResponseFindWishlist.builder()
                .data(wishlistData)
                .build();

        return ResponseEntity.status(HttpStatus.OK).body(response);
    }

    // 위시리스트 상세 조회
    @GetMapping("/detail/{wishlistPk}")
    public ResponseEntity<ResponseFindDetailWishlist> getWishlistDetail(@PathVariable Long wishlistPk) {
        Wishlist wishlist = wishlistService.getWishlistDetail(wishlistPk);
        ResponseFindDetailWishlist response = ResponseFindDetailWishlist.builder()
                .wishlistPk(wishlist.getWishlistPk())
                .productNickname(wishlist.getProductNickname())
                .productName(wishlist.getProductName())
                .productPrice(wishlist.getProductPrice())
                .productImageUrl(wishlist.getProductImageUrl())
                .productUrl(wishlist.getProductUrl())
                .isSelected(wishlist.getIsSelected())
                .isCompleted(wishlist.getIsCompleted())
                .depositAccountCode(wishlist.getDepositAccountCode())
                .build();
        return ResponseEntity.status(HttpStatus.OK).body(response);

    }
}
