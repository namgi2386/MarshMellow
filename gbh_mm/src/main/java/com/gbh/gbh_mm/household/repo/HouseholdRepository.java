package com.gbh.gbh_mm.household.repo;

import com.gbh.gbh_mm.household.model.entity.Household;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface HouseholdRepository extends JpaRepository<Household, Long> {

    List<Household> findAllByDateStringBetweenAndUser_UserPkOrderByDateStringAsc
        (String startDate, String endDate, long userPk);
}
