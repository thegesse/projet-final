package com.goose.notspot.model.requestDTO.user;

import jakarta.validation.constraints.NotBlank;

//extra safety for acc deletion(a "are you sure" if u wanna)
public record DeleteAccountRequest(
        @NotBlank
        String password
) {}
