package com.goose.notspot.model.songs.DTO;

public record songDTO(
        Long id,
        String title,
        String artist,
        String audioPath
) {}
