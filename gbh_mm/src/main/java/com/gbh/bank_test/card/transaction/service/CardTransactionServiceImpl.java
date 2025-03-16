package com.gbh.bank_test.card.transaction.service;

import com.gbh.bank_test.card.transaction.repo.CardTransactionRepository;
import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@AllArgsConstructor
public class CardTransactionServiceImpl implements CardTransactionService {
    private final CardTransactionRepository cardTransactionRepository;
}
