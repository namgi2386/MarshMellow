package com.gbh.gbh_mm.wishlist.service;

import com.gbh.gbh_mm.user.model.entity.User;
import com.gbh.gbh_mm.user.repo.UserRepository;
import com.gbh.gbh_mm.wishlist.model.entity.Wishlist;
import com.gbh.gbh_mm.wishlist.repo.WishlistRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class WishlistService {

    @Autowired
    private WishlistRepository wishlistRepository;

    @Autowired
    private UserRepository userRepository;

    // 위시리스트 생성
    @Transactional
    public void createWishlist(Long userPk, Wishlist wishlist) {
        User user = userRepository.findById(userPk)
                .orElseThrow(() -> new RuntimeException("User not found"));

        wishlist.setUser(user);
        wishlistRepository.save(wishlist);
    }


}
