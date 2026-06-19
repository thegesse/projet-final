package com.goose.notspot.model.requestDTO.auth;

import jakarta.validation.constraints.NotBlank;

public record LogoutRequest(
        @NotBlank(message = "Username cant be blank")
        String username
) {
}
