package com.goose.notspot.repository;

import com.goose.notspot.model.playlists.Playlist;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PlaylistRepository extends JpaRepository<Playlist, Long> {
}
