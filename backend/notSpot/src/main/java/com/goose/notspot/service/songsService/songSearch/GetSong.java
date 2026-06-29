package com.goose.notspot.service.songsService.songSearch;

import com.goose.notspot.model.songs.DTO.SongDTO;
import com.goose.notspot.model.songs.Song;
import com.goose.notspot.repository.SongRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class GetSong {
    private final SongRepository songRepository;

    public GetSong(SongRepository songRepository) {
        this.songRepository = songRepository;
    }

    @Transactional(readOnly = true)
    public SongDTO findSong(Long songId) {

        Song song = songRepository.findById(songId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Song not found"));

        return new SongDTO(song.getId(), song.getTitle(), song.getArtist(),
                "/songs/" + song.getId() + "/stream");
    }
}
