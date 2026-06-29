package com.goose.notspot.service.songsService.songStream;

import com.goose.notspot.model.songs.Song;
import com.goose.notspot.repository.SongRepository;
import com.goose.notspot.service.songsService.songStorage.StoreSongService;
import org.springframework.core.io.Resource;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

@Service
public class StreamSongService {
    private final SongRepository songRepository;
    private final StoreSongService storeSongService;

    public StreamSongService(SongRepository songRepository, StoreSongService storeSongService) {
        this.songRepository = songRepository;
        this.storeSongService = storeSongService;
    }

    @Transactional(readOnly = true)
    public StreamResource streamSong(Long songId) {
        //nevermind forgot exceptions existed
        Song song = songRepository.findById(songId)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "song not found"));

        Resource resource = storeSongService.load(song.getAudioPath());
        return new StreamResource(resource, song.getContentType(), song.getFileSize());
    }
}
