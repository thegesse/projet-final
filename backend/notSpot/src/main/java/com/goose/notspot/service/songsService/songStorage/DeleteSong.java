package com.goose.notspot.service.songsService.songStorage;

import com.goose.notspot.model.playlists.Playlist;
import com.goose.notspot.model.songs.Song;
import com.goose.notspot.repository.PlaylistRepository;
import com.goose.notspot.repository.SongRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class DeleteSong {

    private final SongRepository songRepository;
    private final PlaylistRepository playlistRepository;
    private final StoreSongService storeSongService;

    public DeleteSong(SongRepository songRepository, PlaylistRepository playlistRepository, StoreSongService storeSongService) {
        this.songRepository = songRepository;
        this.playlistRepository = playlistRepository;
        this.storeSongService = storeSongService;
    }

    //transactional for rollback DB changes in case of fail
    @Transactional
    public void deleteSong(Long id) {
        Song song = songRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Song not found"));

        //many to many == delete chosen song from all playlists
        List<Playlist> playlists = playlistRepository.findBySongsContaining(song);
        for (Playlist playlist : playlists) {
            playlist.getSongs().remove(song);
        }

        playlistRepository.saveAll(playlists);
        songRepository.delete(song);
        storeSongService.delete(song.getAudioPath());
    }
}
