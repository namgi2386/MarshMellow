package com.gbh.gbh_mm.wishlist.repo;

import com.gbh.gbh_mm.wishlist.model.entity.Wishlist;
import org.springframework.data.jpa.repository.JpaRepository;

public interface WishlistRepository extends JpaRepository<Wishlist, Long> {
}
