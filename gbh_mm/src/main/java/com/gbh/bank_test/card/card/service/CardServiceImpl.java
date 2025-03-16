package com.gbh.bank_test.card.card.service;

import com.gbh.bank_test.card.card.model.entity.CardBenefit;
import com.gbh.bank_test.card.card.repo.BenefitRepository;
import com.gbh.bank_test.card.card.repo.CardBenefitRepository;
import com.gbh.bank_test.card.card.repo.CardRepository;
import com.gbh.bank_test.card.card.repo.CardTypeRepository;
import com.gbh.bank_test.card.card.repo.UserCardRepository;
import lombok.AllArgsConstructor;
import org.modelmapper.ModelMapper;
import org.springframework.stereotype.Service;

@Service
@AllArgsConstructor
public class CardServiceImpl implements CardService {
    private final CardRepository cardRepository;
    private final CardBenefitRepository cardBenefitRepository;
    private final BenefitRepository benefitRepository;
    private final UserCardRepository userCardRepository;
    private final CardTypeRepository cardTypeRepository;

    private final ModelMapper mapper;
}
