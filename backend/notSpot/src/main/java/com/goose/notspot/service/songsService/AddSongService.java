package com.goose.notspot.service.songsService;

import com.goose.notspot.repository.SongRepository;
import org.springframework.stereotype.Service;

@Service
public class AddSongService {
    private final SongRepository songRepository;

    public AddSongService(SongRepository songRepository) {
        this.songRepository = songRepository;
    }

}
