package com.goose.notspot.model.requestDTO;

import jakarta.validation.constraints.NotBlank;

public record RenamePlaylistRequest(
        @NotBlank
        String title
) {
}
