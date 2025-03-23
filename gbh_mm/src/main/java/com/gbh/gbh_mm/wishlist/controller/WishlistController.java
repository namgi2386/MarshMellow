package com.gbh.gbh_mm.wishlist.controller;

import com.gbh.gbh_mm.wishlist.model.entity.Wishlist;
import com.gbh.gbh_mm.wishlist.model.response.ResponseCreateWishlist;
import com.gbh.gbh_mm.wishlist.service.WishlistService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

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
}
