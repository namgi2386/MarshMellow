package com.gbh.bank_test.card.transaction.controller;

import com.gbh.bank_test.card.card.service.CardService;
import lombok.AllArgsConstructor;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/card-transaction")
@AllArgsConstructor
public class CardController{

    private final CardService cardService;

}
