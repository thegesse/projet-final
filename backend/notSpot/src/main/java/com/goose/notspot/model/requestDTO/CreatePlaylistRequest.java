package com.goose.notspot.model.requestDTO;

import jakarta.validation.constraints.NotBlank;

public record CreatePlaylistRequest(
        @NotBlank
        String title
) {}
