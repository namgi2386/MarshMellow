package com.gbh.gbh_mm.household.controller;

import com.gbh.gbh_mm.household.service.HouseholdService;
import lombok.AllArgsConstructor;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/household")
@AllArgsConstructor
public class HouseholdController {
    private final HouseholdService householdService;
}
