package com.gbh.gbh_cert.controller;


import com.gbh.gbh_cert.model.dto.request.CIRequestDto;
import com.gbh.gbh_cert.model.dto.request.CertExistRequestDto;
import com.gbh.gbh_cert.model.dto.request.CertIssueRequestDto;
import com.gbh.gbh_cert.model.dto.response.CIResponseDto;
import com.gbh.gbh_cert.model.dto.response.CertExistResponseDto;
import com.gbh.gbh_cert.model.dto.response.CertResponseDto;
import com.gbh.gbh_cert.service.CertService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RequiredArgsConstructor
@RestController
@RequestMapping("/api/cert")
public class CertController {

    private final CertService certService;

    @PostMapping("/ci")
    public CIResponseDto generateCi(@Valid @RequestBody CIRequestDto ciRequestDto) {
        return certService.getConnectionInformation(ciRequestDto);
    }

    @PostMapping("/exist")
    public CertExistResponseDto isExistCertificate(@RequestBody CertExistRequestDto certExistRequestDto){
        return certService.checkCertificateExistence(certExistRequestDto);
    }

    @PostMapping("/issue")
    public CertResponseDto issueCertificate(@RequestBody CertIssueRequestDto certIssueRequestDto) throws Exception {
        return certService.createCertificate(certIssueRequestDto);
    }

}
