package com.goose.notspot.model.songs.DTO;

public record SongDTO(
        Long id,
        String title,
        String artist,
        String streamUrl
) {}
