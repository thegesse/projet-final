package com.goose.notspot.repository;

import com.goose.notspot.model.songs.Song;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface SongRepository extends JpaRepository<Song, Long> {
    List<Song> findByTitleContainingIgnoreCase(String title);
    List<Song> findByArtistContainingIgnoreCase(String artist);

    @Query(value = "SELECT * FROM songs ORDER BY RANDOM() LIMIT 1", nativeQuery = true)
    Optional<Song> findRandomSong();
}
