package com.gbh.gbh_mm.wishlist.model.response;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class ResponseUpdateWishlist {
    private String message;

    private Long wishlistPk;

    private String oldNickname;
    private String newNickname;

    private String oldProductName;
    private String newProductName;

    private Long oldProductPrice;
    private Long newProductPrice;

    private String oldProductImageUrl;
    private String newProductImageUrl;

    private String oldProductUrl;
    private String newProductUrl;

}
