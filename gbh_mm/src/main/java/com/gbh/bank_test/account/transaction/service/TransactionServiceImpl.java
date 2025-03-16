package com.gbh.bank_test.account.transaction.service;

import com.gbh.bank_test.account.transaction.repo.PaymentRepository;
import com.gbh.bank_test.account.transaction.repo.ProductRepository;
import com.gbh.bank_test.account.transaction.repo.TransactionRepository;
import lombok.AllArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.stereotype.Service;

@Service
@AllArgsConstructor
public class TransactionServiceImpl implements TransactionService {
    private final TransactionRepository transactionRepository;
    private final PaymentRepository paymentRepository;
    private final ProductRepository productRepository;

    private final ModelMapper mapper;

}
