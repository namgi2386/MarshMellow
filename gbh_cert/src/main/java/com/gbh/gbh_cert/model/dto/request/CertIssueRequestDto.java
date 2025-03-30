package com.gbh.gbh_cert.model.dto.request;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CertIssueRequestDto {
    private String csrPem;
    private String userEmail;
    private String connectionInformation;
    private String userName;
    private String phoneNumber;
    private String birth;
}
