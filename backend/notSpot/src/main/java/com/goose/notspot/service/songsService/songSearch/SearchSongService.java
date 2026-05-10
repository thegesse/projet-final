package com.goose.notspot.service.songsService.songSearch;

import com.goose.notspot.model.songs.DTO.SongDTO;
import com.goose.notspot.model.songs.Song;
import com.goose.notspot.repository.SongRepository;
import org.springframework.stereotype.Service;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
public class SearchSongService {
    private final SongRepository songRepository;

    public SearchSongService(SongRepository songRepository) {
        this.songRepository = songRepository;
    }

    private SongDTO mapToDTO(Song song) {
        Long id = song.getId();
        String title = song.getTitle();
        String artist = song.getArtist();

        return new SongDTO(id, title, artist, "/songs/" + id + "/stream");
    }

    public List<SongDTO> search(String query) {
        if(query == null || query.isBlank()) {
            return List.of();
        }

        Map<Long, Song> results = new LinkedHashMap<>();

        songRepository.findByArtistContainingIgnoreCase(query)
                .forEach(song -> results.put(song.getId(), song));
        songRepository.findByTitleContainingIgnoreCase(query)
                .forEach(song -> results.put(song.getId(), song));

        return results.values()
                .stream()
                .map(this::mapToDTO)
                .toList();
    }
}
