package com.goose.notspot.repository;

import com.goose.notspot.model.playlists.playlist;
import org.springframework.data.jpa.repository.JpaRepository;

public interface playlistRepository extends JpaRepository<playlist,Long> {
}
