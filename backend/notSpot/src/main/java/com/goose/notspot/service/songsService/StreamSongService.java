package com.goose.notspot.service.songsService;

import com.goose.notspot.model.songs.Song;
import com.goose.notspot.repository.SongRepository;
import org.springframework.core.io.Resource;
import org.springframework.stereotype.Service;

@Service
public class StreamSongService {
    private final SongRepository songRepository;
    private final StoreSongService storeSongService;

    public StreamSongService(SongRepository songRepository, StoreSongService storeSongService) {
        this.songRepository = songRepository;
        this.storeSongService = storeSongService;
    }

    public StreamResource streamSong(Long songId) {
        //orElse null bc Im too lazy to add optional to the songrepo
        Song song = songRepository.findById(songId).orElse(null);

        Resource resource = storeSongService.load(song.getAudioPath());
        return new StreamResource(resource, song.getContentType(), song.getFileSize());
    }
}
