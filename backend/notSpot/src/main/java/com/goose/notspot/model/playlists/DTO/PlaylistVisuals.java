package com.goose.notspot.model.playlists.DTO;

import com.goose.notspot.model.songs.DTO.SongDTO;

import java.util.List;

public record PlaylistVisuals(
   Long id,
   String title,
   List<SongDTO> songs
) {}
