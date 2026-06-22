package com.goose.notspot.service.songsService.songStorage;

import com.goose.notspot.model.requestDTO.song.CreateSongRequest;
import com.goose.notspot.model.songs.DTO.SongDTO;
import com.goose.notspot.model.songs.Song;
import com.goose.notspot.repository.SongRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

@Service
public class AddSongService {
    private final SongRepository songRepository;
    private final StoreSongService storeSongService;

    public AddSongService(SongRepository songRepository, StoreSongService storeSongService) {
        this.songRepository = songRepository;
        this.storeSongService = storeSongService;
    }

    @Transactional
    public SongDTO addSong(CreateSongRequest request, MultipartFile file) {
        if(file == null || file.isEmpty()) {
            throw new IllegalArgumentException("audio file needed");
        }

        String audioPath = storeSongService.save(file);

        Song song = new Song();
        song.setTitle(request.title());
        song.setArtist(request.artist());
        song.setAudioPath(audioPath);
        song.setContentType(file.getContentType());
        song.setFileSize(file.getSize());
        Song savedSong = songRepository.save(song);

        return new SongDTO(savedSong.getId(), savedSong.getTitle(), savedSong.getArtist(),
                "/songs/" + savedSong.getId() + "/stream");
    }
}
