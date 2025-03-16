package com.gbh.bank_test.loan.controller;

import com.gbh.bank_test.loan.service.LoanService;
import lombok.AllArgsConstructor;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/loan")
@AllArgsConstructor
public class LoanController {
    private final LoanService loanService;
}
