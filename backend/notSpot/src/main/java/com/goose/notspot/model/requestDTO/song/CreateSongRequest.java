package com.goose.notspot.model.requestDTO.song;

import jakarta.validation.constraints.NotBlank;

public record CreateSongRequest(
        @NotBlank
        String title,
        @NotBlank
        String artist
) {}
