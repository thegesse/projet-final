package com.goose.notspot.service.songsService;

import com.goose.notspot.model.songs.DTO.SongDTO;
import com.goose.notspot.model.songs.Song;
import com.goose.notspot.repository.SongRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class GetAllSongs {
    private final SongRepository songRepository;
    public GetAllSongs(SongRepository songRepository) {
        this.songRepository = songRepository;
    }

    private SongDTO mapToDTO(Song song) {
        Long id = song.getId();
        String title = song.getTitle();
        String artist = song.getArtist();

        return new SongDTO(id, title, artist, "/songs/" + id + "/stream");
    }

    public List<SongDTO> findAll() {
        return songRepository.findAll()
                .stream()
                .map(this::mapToDTO)
                .toList();
    }

}
