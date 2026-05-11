package com.goose.notspot.service.songsService.songSearch;

import com.goose.notspot.model.songs.DTO.SongDTO;
import com.goose.notspot.model.songs.Song;
import com.goose.notspot.repository.SongRepository;
import org.springframework.stereotype.Service;


@Service
public class GetRandomSong {
    private final SongRepository songRepository;

    public GetRandomSong(SongRepository songRepository) {
        this.songRepository = songRepository;
    }

    public SongDTO getRandomSong() {
        Song song = songRepository.findRandomSong()
                .orElseThrow(() -> new RuntimeException("No songs found"));

        return new SongDTO(song.getId(), song.getTitle(), song.getArtist(),
                "/songs/" + song.getId() + "/stream");
    }
}
