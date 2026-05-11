package com.goose.notspot.model.requestDTO.user;

import jakarta.validation.constraints.NotBlank;

public record ChangeUsernameRequest(
        @NotBlank
        String username
) {
}
