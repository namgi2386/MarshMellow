package com.gbh.gbh_mm.household.repo;

import com.gbh.gbh_mm.household.model.entity.Household;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface HouseholdRepository extends JpaRepository<Household, Long> {

    List<Household> findAllByTradeDateBetweenAndUser_UserPkOrderByTradeDateAsc
            (String startDate, String endDate, long userPk);

    List<Household> findTop2ByUser_UserPkOrderByTradeDateDesc(long userPk);

    List<Household> findAllByTradeDateBetweenAndUser_UserPkAndHouseholdMemoOrderByTradeDateAsc
            (String startDate, String endDate, long userPk, String keyword);

    @Query("SELECT h FROM Household h " +
            "WHERE h.tradeDate BETWEEN :startDate AND :endDate " +
            "AND h.user.userPk = :userPk " +
            "AND (h.householdMemo LIKE CONCAT('%', :keyword, '%') " +
            "OR h.tradeName LIKE CONCAT('%', :keyword, '%')) " +
            "ORDER BY h.tradeDate ASC")
    List<Household> searchHousehold(
            @Param("startDate") String startDate,
            @Param("endDate") String endDate,
            @Param("userPk") long userPk,
            @Param("keyword") String keyword
    );
}
