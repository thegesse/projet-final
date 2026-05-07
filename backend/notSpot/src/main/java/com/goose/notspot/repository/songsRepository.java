package com.goose.notspot.repository;

import com.goose.notspot.model.songs.songs;
import org.springframework.data.jpa.repository.JpaRepository;

public interface songsRepository extends JpaRepository<songs,Long> {
}
