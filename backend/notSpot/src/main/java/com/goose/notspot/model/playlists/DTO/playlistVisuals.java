package com.goose.notspot.model.playlists.DTO;

import com.goose.notspot.model.songs.DTO.songDTO;

import java.util.List;

public record playlistVisuals(
   Long id,
   String title,
   List<songDTO> songs
) {}
