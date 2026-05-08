package com.goose.notspot.service.songsService;

import com.goose.notspot.repository.SongRepository;
import org.springframework.stereotype.Service;

@Service
public class StoreSongService {
    private SongRepository songRepository;

    public StoreSongService(SongRepository songRepository) {
        this.songRepository = songRepository;
    }

    //TODO use UUID for storing the file, too lazy to do it rn
}
