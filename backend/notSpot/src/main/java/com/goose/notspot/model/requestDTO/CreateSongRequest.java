package com.goose.notspot.model.requestDTO;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record CreateSongRequest(
        @NotBlank
        String title,
        @NotBlank
        String artist
) {}
