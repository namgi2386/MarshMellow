package com.gbh.bank_test.bank.service;

import com.gbh.bank_test.bank.repo.BankRepository;
import lombok.AllArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.stereotype.Service;

@Service
@AllArgsConstructor
public class BankServiceImpl implements BankService {
    private BankRepository bankRepository;
    private ModelMapper mapper;
}
