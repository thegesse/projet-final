package com.goose.notspot.repository;

import com.goose.notspot.model.playlists.Playlist;
import com.goose.notspot.model.songs.Song;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface PlaylistRepository extends JpaRepository<Playlist, Long> {
    List<Playlist> findBySongsContaining(Song song);
}
