package com.gbh.bank_test.loan.service;

import com.gbh.bank_test.loan.repo.LoanRepaymentRepository;
import com.gbh.bank_test.loan.repo.LoanRepository;
import com.gbh.bank_test.loan.repo.UserLoanRepository;
import lombok.AllArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.stereotype.Service;

@Service
@AllArgsConstructor
public class LoanServiceImpl implements LoanService{
    private final LoanRepository loanRepository;
    private final UserLoanRepository userLoanRepository;
    private final LoanRepaymentRepository loanRepaymentRepository;

    private final ModelMapper mapper;
}
