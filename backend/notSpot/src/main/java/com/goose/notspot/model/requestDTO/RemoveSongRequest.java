package com.goose.notspot.model.requestDTO;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

public record RemoveSongRequest(
        @NotNull
        @Positive
        Long songId
) {}
