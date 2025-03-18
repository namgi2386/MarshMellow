package com.gbh.gbh_mm.common.exception;

import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.List;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(CustomException.class)
    public List<ErrorResponseDto> customExceptionHandler(CustomException e) {
        return List.of(ErrorResponseDto.builder()
                .status(e.getErrorCode().getStatus().value())
                .errorCode(e.getErrorCode().getCode())
                .message(e.getErrorCode().getMessage())
                .build());
    }

}
