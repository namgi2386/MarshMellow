package com.gbh.bank_test.bank.controller;

import com.gbh.bank_test.bank.service.BankService;
import lombok.AllArgsConstructor;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/bank")
@AllArgsConstructor
public class BankController {
    private final BankService bankService;
}
