package com.goose.notspot.repository;

import com.goose.notspot.model.songs.Song;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SongRepository extends JpaRepository<Song, Long> {
}
