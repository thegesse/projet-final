package com.goose.notspot.model.requestDTO.auth;

import jakarta.validation.constraints.NotBlank;

public record RefreshTokenRequest(
        @NotBlank(message = "Refresh token cant be blank")
        String refreshToken
) {
}
