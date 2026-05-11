package com.goose.notspot.model.requestDTO.playlist;

import jakarta.validation.constraints.NotBlank;

public record CreatePlaylistRequest(
        @NotBlank
        String title
) {}
